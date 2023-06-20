# frozen_string_literal: true

require 'bundler/setup'
require 'ka-ching-client'
require 'rackup'
require 'rack/unreloader'
require 'roda'
require 'pry'
require 'money'

Unreloader = Rack::Unreloader.new(subclasses: %w[Roda]) { App }
Unreloader.require './app.rb'

run Unreloader
