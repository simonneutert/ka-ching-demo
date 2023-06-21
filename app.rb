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

  res = begin
    client.v1.admin.create!(tenant_account_id: 'testuser_1')
  rescue StandardError
    nil
  end

  route do |r|
    r.assets
    r.public

    r.root do
      view 'index'
    end

    r.on 'actions' do
      view 'actions'
    end

    r.on 'bookings' do
      r.on :id do |id|
        id
      end

      r.is do
        res = client.v1.bookings.unlocked(tenant_account_id: 'testuser_1')
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
          tenant_account_id: 'testuser_1',
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
          tenant_account_id: 'testuser_1'
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
        res = client.v1.lockings.all(tenant_account_id: 'testuser_1')
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
            tenant_account_id: 'testuser_1',
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
            tenant_account_id: 'testuser_1',
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
      res = client.v1.saldo.current(tenant_account_id: 'testuser_1')
      render 'ka-ching/saldo', locals: { saldo: res['saldo'] }
    end

    r.on 'auditlogs' do
      year = r.params.fetch('year', Time.now.year).to_i
      page = r.params.fetch('page', 1).to_i
      per_page = r.params.fetch('per_page', 10).to_i
      @auditlogs = client.v1.audit_logs.of_year(tenant_account_id: 'testuser_1', year:)
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
