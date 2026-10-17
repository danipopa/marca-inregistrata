ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
if ENV.fetch("RAILS_ENV", ENV.fetch("RACK_ENV", "development")) == "development"
  require "dotenv"
  api_root = File.expand_path("..", __dir__)
  Dotenv.load(File.join(api_root, ".env.local"), File.join(api_root, ".env"))
end
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
