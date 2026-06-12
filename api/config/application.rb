require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Api
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    encryption_fallbacks = Rails.env.production? ? {} : {
      primary_key: "a" * 64,
      deterministic_key: "b" * 64,
      key_derivation_salt: "c" * 64
    }
    config.active_record.encryption.primary_key =
      ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"].presence ||
      credentials.dig(:active_record_encryption, :primary_key).presence ||
      encryption_fallbacks[:primary_key]
    config.active_record.encryption.deterministic_key =
      ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"].presence ||
      credentials.dig(:active_record_encryption, :deterministic_key).presence ||
      encryption_fallbacks[:deterministic_key]
    config.active_record.encryption.key_derivation_salt =
      ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"].presence ||
      credentials.dig(:active_record_encryption, :key_derivation_salt).presence ||
      encryption_fallbacks[:key_derivation_salt]
  end
end
