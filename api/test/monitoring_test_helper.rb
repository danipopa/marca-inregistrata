require "test_helper"

module MonitoringTestHelper
  def monitoring_order(**attributes)
    user = User.create_with_password!(email: "monitoring@example.com", password: "password123")
    TrademarkRequest.create!({ user: user, mark: "EXAMPLE", email: user.email,
      phone: "0712345678", product_code: "monitoring-brand", payment_method: "transfer",
      registration_number: "000123", registration_office: "OSIM" }.merge(attributes))
  end

  def sample_match(id: "new-1", name: "EXAMPLE PLUS")
    { id: id, name: name, office: "OSIM", status: "application", source_url: "https://example.org/trademarks/#{id}" }
  end

  def fake_provider(results: [], error: nil)
    provider = Object.new
    provider.define_singleton_method(:name) { "test-only" }
    provider.define_singleton_method(:configured?) { true }
    provider.define_singleton_method(:search) do |subscription:|
      raise error if error

      results
    end
    provider
  end

  def with_provider(provider)
    original = TrademarkMonitoring::Provider.method(:current)
    TrademarkMonitoring::Provider.define_singleton_method(:current) { provider }
    yield
  ensure
    TrademarkMonitoring::Provider.define_singleton_method(:current, original)
  end
end
