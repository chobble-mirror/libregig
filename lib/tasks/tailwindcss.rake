namespace :tailwindcss do
  desc "Build Tailwind CSS"
  task build: :environment do
    # Use which to find the system tailwindcss, bypassing bundler
    tailwind_path = `which tailwindcss`.strip
    if tailwind_path.empty?
      abort("tailwindcss not found in PATH. Make sure you're in the nix shell.")
    end

    system(
      tailwind_path,
      "--config", Rails.root.join("config/tailwind.config.js").to_s,
      "--input", Rails.root.join("app/assets/stylesheets/application.tailwind.css").to_s,
      "--output", Rails.root.join("app/assets/stylesheets/tailwind.css").to_s,
      "--minify"
    ) || abort("Failed to build Tailwind CSS")
  end

  desc "Watch Tailwind CSS for changes"
  task watch: :environment do
    # Use which to find the system tailwindcss, bypassing bundler
    tailwind_path = `which tailwindcss`.strip
    if tailwind_path.empty?
      abort("tailwindcss not found in PATH. Make sure you're in the nix shell.")
    end

    system(
      tailwind_path,
      "--config", Rails.root.join("config/tailwind.config.js").to_s,
      "--input", Rails.root.join("app/assets/stylesheets/application.tailwind.css").to_s,
      "--output", Rails.root.join("app/assets/stylesheets/tailwind.css").to_s,
      "--watch"
    )
  end
end

# Hook into assets:precompile
if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["tailwindcss:build"])
end

# Hook into test:prepare
if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["tailwindcss:build"])
end
