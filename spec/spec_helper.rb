ENV['RAILS_ENV'] ||= 'test'
ENV['ORM']       ||= 'nobrainer'

require 'bundler/setup'
Bundler.setup

require 'rack/test'
require 'factory_girl'
require 'ffaker'
require 'pry'
require 'awesome_print'
require 'rspec/its'
require 'coveralls'

if Coveralls.should_run?
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end

ORM_GEMS_MAPPING = {
  'nobrainer' => 'nobrainer'
}.freeze

require ORM_GEMS_MAPPING[ENV['ORM']]

require File.expand_path("../dummy/orm/#{ENV['ORM']}/app/twitter", __FILE__)
APP = Rack::Builder.parse_file(File.expand_path("../dummy/orm/#{ENV['ORM']}/config.ru", __FILE__)).first

require "support/config/#{ORM_GEMS_MAPPING[ENV['ORM']]}"
require 'support/helper'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Helper

  config.filter_run_excluding skip_if: true

  config.order = :random
  config.color = true

  config.before(:all) do
    if ENV['ORM'] == 'nobrainer'
      NoBrainer.configure(&NOBRAINER_CONF)
      NoBrainer.sync_schema
    end
  end

  config.before(:suite) do
    FactoryGirl.find_definitions
  end

  config.before(:each) do
    if ENV['ORM'] == 'nobrainer'
      NoBrainer.configure(&NOBRAINER_CONF)
      NoBrainer.purge!
      NoBrainer::Loader.cleanup
    end
  end
end