Rails.backtrace_cleaner.add_silencer { |line| line =~ %r{/usr/lib/ruby/1.9.1/rake.rb} }
