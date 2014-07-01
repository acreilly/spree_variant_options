# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'active_support'
require 'active_support/test_case'
require 'rails/test_help'
require 'test/unit'
require 'shoulda'
require 'factory_girl'
require 'capybara/rails'
require 'database_cleaner'
require 'deface'

begin; require "debugger"; rescue LoadError; end
begin; require "turn"; rescue LoadError; end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

DatabaseCleaner.strategy = :truncation
Capybara.default_driver = :selenium

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  include Spree::UrlHelpers

  # Stop ActiveRecord from wrapping tests in transactions
  self.use_transactional_fixtures = false

  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
end

class ActiveSupport::TestCase
  # make Factory Girl syntax available without FactoryGirl.
  include FactoryGirl::Syntax::Methods
  # make spree factories available
  require 'ffaker'
  require 'spree/testing_support/factories'
end
