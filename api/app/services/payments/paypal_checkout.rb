require "net/http"

module Payments
  class PaypalCheckout
    def self.create!(trademark_request)
      new(trademark_request).create!
    end

    def initialize(trademark_request)
      @trademark_request = trademark_request
    end

    def create!
      raise MissingCredentials, "PAYPAL_CLIENT_ID or PAYPAL_CLIENT_SECRET is missing" if client_id.blank? || client_secret.blank?

      response = post_json("#{base_url}/v2/checkout/orders", order_payload, access_token)
      payload = JSON.parse(response.body)

      raise ProviderError, payload["message"] || "PayPal order creation failed" unless response.is_a?(Net::HTTPSuccess)

      approve_link = payload.fetch("links").find { |link| link["rel"] == "approve" }&.fetch("href")
      raise ProviderError, "PayPal approval URL was not returned" if approve_link.blank?

      {
        provider: "paypal",
        provider_id: payload.fetch("id"),
        checkout_url: approve_link
      }
    end

    private

    attr_reader :trademark_request

    class MissingCredentials < StandardError; end
    class ProviderError < StandardError; end

    def access_token
      uri = URI("#{base_url}/v1/oauth2/token")
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(client_id, client_secret)
      request["Accept"] = "application/json"
      request["Accept-Language"] = "en_US"
      request.set_form_data(grant_type: "client_credentials")

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
      payload = JSON.parse(response.body)

      raise ProviderError, payload["error_description"] || "PayPal authentication failed" unless response.is_a?(Net::HTTPSuccess)

      payload.fetch("access_token")
    end

    def post_json(url, payload, token)
      uri = URI(url)
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{token}"
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(payload)

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    end

    def order_payload
      {
        intent: "CAPTURE",
        purchase_units: [
          {
            reference_id: trademark_request.id.to_s,
            description: "#{trademark_request.product_name} - #{trademark_request.mark}",
            amount: {
              currency_code: "EUR",
              value: paypal_amount_eur
            }
          }
        ],
        application_context: {
          return_url: "#{frontend_url}/account?payment=success&order=#{trademark_request.id}",
          cancel_url: "#{frontend_url}/?payment=cancelled#formular",
          user_action: "PAY_NOW"
        }
      }
    end

    def base_url
      ENV.fetch("PAYPAL_BASE_URL", "https://api-m.sandbox.paypal.com")
    end

    def client_id
      ENV["PAYPAL_CLIENT_ID"].to_s
    end

    def client_secret
      ENV["PAYPAL_CLIENT_SECRET"].to_s
    end

    def paypal_amount_eur
      format("%.2f", trademark_request.total_lei / ron_per_eur)
    end

    def ron_per_eur
      ENV.fetch("PAYPAL_RON_PER_EUR", "5").to_d
    end

    def frontend_url
      ENV.fetch("FRONTEND_URL", "http://localhost:3000")
    end
  end
end
