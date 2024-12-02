ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
require_relative "validate_shoulda_test_syntax"

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include ActiveSupport::Testing::TimeHelpers

  parallelize(workers: :number_of_processors)

  parallelize_setup do |worker|
    SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
  end

  parallelize_teardown do |worker|
    SimpleCov.result
  end

  fixtures :all

  def log_in_as(user)
    post login_path,
      params: {
        user: {
          username: user.username,
          password: "password"
        }
      }
    follow_redirect!
  end

  setup do
    ValidateShouldaTestSyntax.validate(self)
  end
end

class Current < ActiveSupport::CurrentAttributes
  attribute :user
end

module BCrypt
  # don't need proper encryption when doing tests
  class Password
    def initialize(encrypted)
      @encrypted = encrypted
    end

    def is_password?(unencrypted)
      @encrypted == unencrypted.reverse
    end

    def self.create(unencrypted, **)
      unencrypted.reverse
    end
  end
end
