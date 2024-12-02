# lib/tasks/precommit.rake
namespace :precommit do
  desc "Run standard and tests before committing"

  task all: [:environment] do
    # Run standard:fix with backtrace suppression
    puts "Running standard..."
    std_output = `bundle exec rake standard`
    std_status = $?.exitstatus

    if std_status != 0
      puts "standard failed, aborting - try running 'rake standard:fix' first"
      puts std_output.lines.grep_v(/^\s+from /).join # Suppress backtrace lines
      exit 1
    else
      puts "standard passed."
    end

    # Run rails test
    puts "Running tests..."
    test_output = `bundle exec rails test`
    test_status = $?.exitstatus

    if test_status != 0
      puts "Tests failed. Aborting commit."
      puts test_output.lines.grep_v(/^\s+from /).join # Suppress backtrace lines
      exit 1
    else
      puts "All tests passed."
    end
  end
end
