# frozen_string_literal: true

require 'bundler/setup'

require 'ka-ching-client'
require 'rackup'
require 'rack/unreloader'
require 'roda'
require 'pry'
require 'money'

prod = ENV['RACK_ENV'] == 'production'

Unreloader = Rack::Unreloader.new(subclasses: %w[Roda]) { App }
Unreloader.require './app.rb'

run(prod ? App : Unreloader)
