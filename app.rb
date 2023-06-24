# frozen_string_literal: true

I18n.config.available_locales = :en
Money.locale_backend = :i18n

BACKEND_API_URL = ENV.fetch('API_URL', 'http://0.0.0.0:9292')

# Runs a basic roda app
class App < Roda
  plugin :render
  plugin :assets, css: 'style.css', js: 'script.js'
  plugin :public, root: 'public'
  plugin :all_verbs

  client = KaChing::ApiClient.new(api_version: :v1, base_url: BACKEND_API_URL)
                             .build_client!

  if ENV.fetch("CREATE_DEMO_TENANT", false) != 'false'
    begin
      client.v1.admin.create!(tenant_account_id: 'testuser_1')
    rescue StandardError => e
      puts e
    end
  end

  route do |r|
    r.assets
    r.public

    r.root do
      begin
        res = client.v1.tenants.all(page: 1)
        @tenants = res['items']
      rescue StandardError => e
        puts e
      else
        @tenants.map! do |tenant|
          tenant['tenant_db_id'].gsub!('kaching_tenant_', '')
        end
        ensure @tenants ||= []
      end

      view 'index'
    end

    r.on 'admin' do
      r.on 'tenants' do
        r.post do
          tenant_account_id = r.params['tenant_account_id']
          begin
            raise ArgumentError, "name should match regexp: /^[a-z0-9_]+$/" unless tenant_account_id.match?(/^[a-z0-9_]+$/)
            client.v1.admin.create!(tenant_account_id: tenant_account_id)
            content = <<~HTML
            <div id="tenant-notification" class="columns">
              <div class="column is-three-quarters-mobile is-two-thirds-tablet is-half-desktop">
                <div class="notification is-info">
                  <button class="delete" onclick="window.location = '/#{tenant_account_id}/actions'"></button>
                  Tenant #{tenant_account_id} created successfully.
                  <p class="button is-primary" onclick="window.location = '/#{tenant_account_id}/actions'">Go to tenant</p>
                </div>
              </div>
            </div>
            HTML
          rescue => exception
            @error = exception.message
            content = <<~HTML
            <div id="tenant-notification" class="columns">
              <div class="column is-three-quarters-mobile is-two-thirds-tablet is-half-desktop">
                <div class="notification is-danger">
                  <button class="delete" onclick="window.location = '/'"></button>
                  #{@error}
                </div>
              </div>
            </div>
            HTML
          end
        end
      end
    end

    r.on String do |tenant_account_id|
      if %w[
        actions bookings lockings lock deposit withdraw saldo auditlogs
      ].include?(tenant_account_id)
        r.redirect '/testuser_1/actions'
        r.halt
      end

      @tenant_account_id = tenant_account_id

      r.on 'actions' do
        view 'actions'
      end

      r.on 'bookings' do
        r.on :id do |id|
          id
        end

        r.is do
          res = client.v1.bookings.unlocked(tenant_account_id:)
          @bookings = res['bookings']
          @bookings.map! do |booking|
            booking['context'] = JSON.parse(booking['context'])['content']
            booking['realized_at'] = Time.parse(booking['realized_at'])
            booking
          end
          @bookings.sort_by! { |booking| booking['realized_at'] }

          render 'bookings'
        end
      end

      r.on 'lock' do
        r.post do
          res = client.v1.lockings.lock!(
            tenant_account_id:,
            amount_cents_saldo_user_counted: r.params['amount_cents'].to_i,
            year: r.params['year'].to_i,
            month: r.params['month'].to_i,
            day: r.params['day'].to_i,
            context: { content: r.params['context'] }
          )
          render 'ka-ching/lock'
        end

        r.delete do
          res = client.v1.lockings.unlock!(
            tenant_account_id:
          )
          content = <<~HTML
            <div hx-get="/saldo" hx-target="#saldo" hx-trigger="load delay:1ms"></div>
            <div hx-get="/bookings" hx-target="#bookings" hx-trigger="load delay:1ms"></div>
          HTML
          content
        end

        r.is do
          render 'ka-ching/lock'
        end
      end

      r.on 'lockings' do
        r.is do
          res = client.v1.lockings.all(tenant_account_id:)
          @lockings = res['items']
          @lockings.map! do |locking|
            locking['context'] = JSON.parse(locking['context'])['content']
            locking['realized_at'] = Time.parse(locking['realized_at'])
            locking['bookings'] = JSON.parse(locking['bookings_json']).map do |booking|
              booking['context'] = JSON.parse(booking['context'])['content']
              booking['realized_at'] = Time.parse(booking['realized_at'])
              booking
            end
            locking
          end
          view 'lockings'
        end

        r.on :id do |id|
          id
        end
      end

      r.on 'deposit' do
        r.post do
          begin
            res = client.v1.bookings.deposit!(
              tenant_account_id:,
              amount_cents: r.params['amount_cents'].to_i,
              year: r.params['year'].to_i,
              month: r.params['month'].to_i,
              day: r.params['day'].to_i,
              context: { content: r.params['context'] }
            )
          rescue StandardError => e
            puts e
            error_body = JSON.parse(e.response[:body])
            @error = error_body['message'] || error_body['status']
          end
          render 'ka-ching/deposit'
        end

        r.get do
          render 'ka-ching/deposit'
        end
      end

      r.on 'withdraw' do
        r.post do
          begin
            res = client.v1.bookings.withdraw!(
              tenant_account_id:,
              amount_cents: r.params['amount_cents'].to_i,
              year: r.params['year'].to_i,
              month: r.params['month'].to_i,
              day: r.params['day'].to_i,
              context: { content: r.params['context'] }
            )
          rescue StandardError => e
            puts e
            @error = JSON.parse(e.response[:body])['message']
          end
          render 'ka-ching/withdraw'
        end

        r.get do
          render 'ka-ching/withdraw'
        end
      end

      r.on 'saldo' do
        res = client.v1.saldo.current(tenant_account_id:)
        render 'ka-ching/saldo', locals: { saldo: res['saldo'] }
      end

      r.on 'auditlogs' do
        year = r.params.fetch('year', Time.now.year).to_i
        page = r.params.fetch('page', 1).to_i
        per_page = r.params.fetch('per_page', 10).to_i
        @auditlogs = client.v1.audit_logs.of_year(tenant_account_id:, year:)
        @auditlogs.map! do |auditlog|
          auditlog['realized_at'] = Time.parse(auditlog['environment_snapshot']['realized_at'])
          auditlog['locking_id'] = auditlog['environment_snapshot']['id']
          auditlog['bookings'] = JSON.parse(auditlog['environment_snapshot']['bookings_json']).map do |booking|
            booking['context'] = JSON.parse(booking['context'])['content']
            booking['realized_at'] = Time.parse(booking['realized_at'])
            booking
          end
          auditlog
        end
        view 'auditlogs'
      end
    end
  end
end
