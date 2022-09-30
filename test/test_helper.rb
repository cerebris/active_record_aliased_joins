# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'active_record_aliased_joins'

require 'minitest/autorun'

ENV['DATABASE_URL'] ||= 'sqlite3:test_db'
Rails.env = 'test'

class TestApp < Rails::Application
  config.eager_load = false
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: 'session'
  config.secret_key_base = 'secret'

  # Raise errors on unsupported parameters
  config.action_controller.action_on_unpermitted_parameters = :raise

  ActiveRecord::Schema.verbose = false
  config.active_record.schema_format = :none
  config.active_support.test_order = :random
end

TestApp.initialize!

module Minitest
  class Test
    include ActiveRecord::TestFixtures

    self.fixture_path = "#{Rails.root}/fixtures"
    fixtures :all
  end
end

require File.expand_path('fixtures/models', __dir__)
