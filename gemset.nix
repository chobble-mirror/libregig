{
  actioncable = {
    dependencies = ["actionpack" "activesupport" "nio4r" "websocket-driver" "zeitwerk"];
  };
  actionmailbox = {
    dependencies = ["actionpack" "activejob" "activerecord" "activestorage" "activesupport" "mail" "net-imap" "net-pop" "net-smtp"];
  };
  actionmailer = {
    dependencies = ["actionpack" "actionview" "activejob" "activesupport" "mail" "net-imap" "net-pop" "net-smtp" "rails-dom-testing"];
  };
  actionpack = {
    dependencies = ["actionview" "activesupport" "nokogiri" "racc" "rack" "rack-session" "rack-test" "rails-dom-testing" "rails-html-sanitizer"];
  };
  actiontext = {
    dependencies = ["actionpack" "activerecord" "activestorage" "activesupport" "globalid" "nokogiri"];
  };
  actionview = {
    dependencies = ["activesupport" "builder" "erubi" "rails-dom-testing" "rails-html-sanitizer"];
  };
  activejob = {
    dependencies = ["activesupport" "globalid"];
  };
  activemodel = {
    dependencies = ["activesupport"];
  };
  activerecord = {
    dependencies = ["activemodel" "activesupport" "timeout"];
  };
  activestorage = {
    dependencies = ["actionpack" "activejob" "activerecord" "activesupport" "marcel"];
  };
  activesupport = {
    dependencies = ["base64" "benchmark" "bigdecimal" "concurrent-ruby" "connection_pool" "drb" "i18n" "logger" "minitest" "mutex_m" "securerandom" "tzinfo"];
  };
  addressable = {
    dependencies = ["public_suffix"];
  };
  ast = {
  };
  base64 = {
  };
  bcrypt = {
  };
  benchmark = {
  };
  better_html = {
    dependencies = ["actionview" "activesupport" "ast" "erubi" "parser" "smart_properties"];
  };
  bigdecimal = {
  };
  bindex = {
  };
  bootsnap = {
    dependencies = ["msgpack"];
  };
  builder = {
  };
  capybara = {
    dependencies = ["addressable" "matrix" "mini_mime" "nokogiri" "rack" "rack-test" "regexp_parser" "xpath"];
  };
  childprocess = {
    dependencies = ["logger"];
  };
  concurrent-ruby = {
  };
  connection_pool = {
  };
  crass = {
  };
  date = {
  };
  debug = {
    dependencies = ["irb" "reline"];
  };
  docile = {
  };
  dotenv = {
  };
  drb = {
  };
  erb_lint = {
    dependencies = ["activesupport" "better_html" "parser" "rainbow" "rubocop" "smart_properties"];
  };
  error_highlight = {
  };
  erubi = {
  };
  factory_bot = {
    dependencies = ["activesupport"];
  };
  factory_bot_rails = {
    dependencies = ["factory_bot" "railties"];
  };
  faraday = {
    dependencies = ["faraday-net_http" "json" "logger"];
  };
  faraday-net_http = {
    dependencies = ["net-http"];
  };
  fast_ignore = {
  };
  globalid = {
    dependencies = ["activesupport"];
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
  };
  importmap-rails = {
    dependencies = ["actionpack" "activesupport" "railties"];
  };
  io-console = {
  };
  irb = {
    dependencies = ["rdoc" "reline"];
  };
  jbuilder = {
    dependencies = ["actionview" "activesupport"];
  };
  json = {
  };
  language_server-protocol = {
  };
  launchy = {
    dependencies = ["addressable" "childprocess"];
  };
  leftovers = {
    dependencies = ["fast_ignore" "parallel" "parser"];
  };
  letter_opener = {
    dependencies = ["launchy"];
  };
  licensed = {
    dependencies = ["json" "licensee" "parallel" "pathname-common_prefix" "reverse_markdown" "ruby-xxHash" "thor" "tomlrb"];
  };
  licensee = {
    dependencies = ["dotenv" "octokit" "reverse_markdown" "rugged" "thor"];
  };
  lint_roller = {
  };
  logger = {
  };
  loofah = {
    dependencies = ["crass" "nokogiri"];
  };
  mail = {
    dependencies = ["mini_mime" "net-imap" "net-pop" "net-smtp"];
  };
  marcel = {
  };
  matrix = {
  };
  mini_mime = {
  };
  minitest = {
  };
  mocha = {
    dependencies = ["ruby2_keywords"];
  };
  msgpack = {
  };
  mutex_m = {
  };
  net-http = {
    dependencies = ["uri"];
  };
  net-imap = {
    dependencies = ["date" "net-protocol"];
  };
  net-pop = {
    dependencies = ["net-protocol"];
  };
  net-protocol = {
    dependencies = ["timeout"];
  };
  net-smtp = {
    dependencies = ["net-protocol"];
  };
  nio4r = {
  };
  nokogiri = {
    dependencies = ["racc"];
  };
  octokit = {
    dependencies = ["faraday" "sawyer"];
  };
  parallel = {
  };
  parallel_tests = {
    dependencies = ["parallel"];
  };
  parser = {
    dependencies = ["ast" "racc"];
  };
  pathname-common_prefix = {
  };
  prosopite = {
  };
  psych = {
    dependencies = ["stringio"];
  };
  public_suffix = {
  };
  puma = {
    dependencies = ["nio4r"];
  };
  racc = {
  };
  rack = {
  };
  rack-session = {
    dependencies = ["rack"];
  };
  rack-test = {
    dependencies = ["rack"];
  };
  rackup = {
    dependencies = ["rack" "webrick"];
  };
  rails = {
    dependencies = ["actioncable" "actionmailbox" "actionmailer" "actionpack" "actiontext" "actionview" "activejob" "activemodel" "activerecord" "activestorage" "activesupport" "railties"];
  };
  rails-controller-testing = {
    dependencies = ["actionpack" "actionview" "activesupport"];
  };
  rails-dom-testing = {
    dependencies = ["activesupport" "minitest" "nokogiri"];
  };
  rails-html-sanitizer = {
    dependencies = ["loofah" "nokogiri"];
  };
  railties = {
    dependencies = ["actionpack" "activesupport" "irb" "rackup" "rake" "thor" "zeitwerk"];
  };
  rainbow = {
  };
  rake = {
  };
  rdoc = {
    dependencies = ["psych"];
  };
  regexp_parser = {
  };
  reline = {
    dependencies = ["io-console"];
  };
  reverse_markdown = {
    dependencies = ["nokogiri"];
  };
  rexml = {
  };
  rubocop = {
    dependencies = ["json" "language_server-protocol" "parallel" "parser" "rainbow" "regexp_parser" "rubocop-ast" "ruby-progressbar" "unicode-display_width"];
  };
  rubocop-ast = {
    dependencies = ["parser"];
  };
  rubocop-performance = {
    dependencies = ["rubocop" "rubocop-ast"];
  };
  rubocop-rails = {
    dependencies = ["activesupport" "rack" "rubocop" "rubocop-ast"];
  };
  ruby-progressbar = {
  };
  ruby-xxHash = {
  };
  ruby2_keywords = {
  };
  rubyzip = {
  };
  rugged = {
  };
  sawyer = {
    dependencies = ["addressable" "faraday"];
  };
  securerandom = {
  };
  selenium-webdriver = {
    dependencies = ["base64" "logger" "rexml" "rubyzip" "websocket"];
  };
  shoulda-context = {
  };
  shoulda-matchers = {
    dependencies = ["activesupport"];
  };
  simplecov = {
    dependencies = ["docile" "simplecov-html" "simplecov_json_formatter"];
  };
  simplecov-html = {
  };
  simplecov-json = {
    dependencies = ["json" "simplecov"];
  };
  simplecov_json_formatter = {
  };
  smart_properties = {
  };
  sprockets = {
    dependencies = ["concurrent-ruby" "rack"];
  };
  sprockets-rails = {
    dependencies = ["actionpack" "activesupport" "sprockets"];
  };
  sqlite3 = {
  };
  standard = {
    dependencies = ["language_server-protocol" "lint_roller" "rubocop" "standard-custom" "standard-performance"];
  };
  standard-custom = {
    dependencies = ["lint_roller" "rubocop"];
  };
  standard-performance = {
    dependencies = ["lint_roller" "rubocop-performance"];
  };
  standard-rails = {
    dependencies = ["lint_roller" "rubocop-rails"];
  };
  stimulus-rails = {
    dependencies = ["railties"];
  };
  stringio = {
  };
  tailwindcss-rails = {
    dependencies = ["railties"];
  };
  thor = {
  };
  timeout = {
  };
  tomlrb = {
  };
  turbo-rails = {
    dependencies = ["actionpack" "railties"];
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
  };
  unicode-display_width = {
  };
  uri = {
  };
  web-console = {
    dependencies = ["actionview" "activemodel" "bindex" "railties"];
  };
  webrick = {
  };
  websocket = {
  };
  websocket-driver = {
    dependencies = ["websocket-extensions"];
  };
  websocket-extensions = {
  };
  xpath = {
    dependencies = ["nokogiri"];
  };
  zeitwerk = {
  };
}
