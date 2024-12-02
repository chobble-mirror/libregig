unless File.exist?(".env")
  raise <<~ERROR_MSG
    The .env file is missing. Please copy env-example to .env to get going.
  ERROR_MSG
end
