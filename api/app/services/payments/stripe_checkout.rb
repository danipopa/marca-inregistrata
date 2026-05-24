require "net/http"

module Payments
  class StripeCheckout
    API_URL = "https://api.stripe.com/v1/checkout/sessions"

    def self.create!(trademark_request)
      new(trademark_request).create!
    end

    def initialize(trademark_request)
      @trademark_request = trademark_request
    end

    def create!
      raise MissingCredentials, "STRIPE_SECRET_KEY is missing" if secret_key.blank?

      response = Net::HTTP.post_form(uri, form_payload)
      payload = JSON.parse(response.body)

      raise ProviderError, payload.dig("error", "message") || "Stripe checkout failed" unless response.is_a?(Net::HTTPSuccess)

      {
        provider: "stripe",
        provider_id: payload.fetch("id"),
        checkout_url: payload.fetch("url")
      }
    end

    private

    attr_reader :trademark_request

    class MissingCredentials < StandardError; end
    class ProviderError < StandardError; end

    def uri
      URI(API_URL).tap do |api_uri|
        api_uri.user = secret_key
        api_uri.password = ""
      end
    end

    def form_payload
      {
        "mode" => "payment",
        "payment_method_types[]" => "card",
        "line_items[0][quantity]" => "1",
        "line_items[0][price_data][currency]" => trademark_request.currency.downcase,
        "line_items[0][price_data][unit_amount]" => trademark_request.total_cents.to_s,
        "line_items[0][price_data][product_data][name]" => trademark_request.product_name,
        "line_items[0][price_data][product_data][description]" => trademark_request.mark,
        "success_url" => "#{frontend_url}/account?payment=success&order=#{trademark_request.id}",
        "cancel_url" => "#{frontend_url}/?payment=cancelled#formular",
        "metadata[trademark_request_id]" => trademark_request.id.to_s
      }
    end

    def secret_key
      ENV["STRIPE_SECRET_KEY"].to_s
    end

    def frontend_url
      ENV.fetch("FRONTEND_URL", "http://localhost:3000")
    end
  end
end
