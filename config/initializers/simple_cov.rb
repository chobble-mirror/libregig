if ENV["RAILS_ENV"] == "test"
  require "simplecov"
  require "simplecov-json"

  SimpleCov.start "rails" do
    enable_coverage :branch
  end

  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ])

  SimpleCov.command_name "Minitest"
end
