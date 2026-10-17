module TrademarkMonitoring
  # Adapters must return a complete, paginated result set with stable IDs.
  # No website endpoint or sample-data adapter is enabled in production.
  class Provider
    class Error < StandardError; end
    class InvalidResponse < Error; end
    class RateLimited < Error
      attr_reader :retry_after

      def initialize(retry_after: 15.minutes)
        @retry_after = retry_after.to_i.clamp(60, 7.days.to_i)
        super("Provider rate limit reached")
      end
    end

    ADAPTERS = {}.freeze

    def self.current
      adapter = ADAPTERS[ENV["TRADEMARK_MONITORING_PROVIDER"]]
      return new unless ENV["TRADEMARK_MONITORING_ENABLED"] == "true" && adapter

      adapter.new
    end

    def name
      "unconfigured"
    end

    def configured?
      false
    end

    def search(subscription:)
      raise Error, "Awaiting API configuration"
    end
  end
end
