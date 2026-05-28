require "json"
require "net/http"
require "uri"

module TrademarkMonitoring
  class TmviewClient
    DEFAULT_ENDPOINT = "https://www.tmdn.org/tmview/api/search/results?translate=true"
    DEFAULT_OFFICES = %w[RO EM].freeze

    class Error < StandardError
      attr_reader :status, :body

      def initialize(message, status: nil, body: nil)
        super(message)
        @status = status
        @body = body
      end
    end

    def self.search(...)
      new.search(...)
    end

    def initialize(endpoint: ENV.fetch("TMVIEW_SEARCH_URL", DEFAULT_ENDPOINT))
      @endpoint = endpoint
    end

    def search(mark:, offices: DEFAULT_OFFICES, classes: [], page_size: 10)
      payload = build_payload(mark:, offices:, classes:, page_size:)
      response = post_json(URI(endpoint), payload)
      parsed = JSON.parse(response.body)

      normalize(parsed, payload)
    rescue JSON::ParserError
      raise Error.new("TMview returned an invalid response.", status: response&.code, body: response&.body)
    end

    private

    attr_reader :endpoint

    def build_payload(mark:, offices:, classes:, page_size:)
      {
        page: 1,
        pageSize: page_size.to_i.clamp(1, 25),
        criteria: "C",
        basicSearch: mark.to_s.strip,
        offices: clean_list(offices).presence || DEFAULT_OFFICES,
        niceClass: clean_list(classes)
      }.compact
    end

    def clean_list(values)
      Array(values).filter_map { |value| value.to_s.strip.presence }
    end

    def post_json(uri, payload)
      request = Net::HTTP::Post.new(uri)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json; charset=utf-8"
      request["User-Agent"] = "inregistrare-marca/1.0"
      request["Authorization"] = "Bearer #{api_token}" if api_token.present?
      request.body = JSON.generate(payload)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 15) do |http|
        http.request(request)
      end

      return response if response.is_a?(Net::HTTPSuccess)

      raise Error.new("TMview search failed.", status: response.code, body: response.body)
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError => error
      raise Error.new("TMview search is unavailable: #{error.message}")
    end

    def api_token
      ENV["TMVIEW_API_TOKEN"].presence || client_credentials_token
    end

    def client_credentials_token
      return unless ENV["EUIPO_TOKEN_URL"].present? && ENV["EUIPO_CLIENT_ID"].present? && ENV["EUIPO_CLIENT_SECRET"].present?

      @client_credentials_token ||= begin
        uri = URI(ENV.fetch("EUIPO_TOKEN_URL"))
        request = Net::HTTP::Post.new(uri)
        request.basic_auth(ENV.fetch("EUIPO_CLIENT_ID"), ENV.fetch("EUIPO_CLIENT_SECRET"))
        request.set_form_data(grant_type: "client_credentials")

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 10) do |http|
          http.request(request)
        end

        JSON.parse(response.body).fetch("access_token") if response.is_a?(Net::HTTPSuccess)
      rescue JSON::ParserError, KeyError
        nil
      end
    end

    def normalize(body, payload)
      results = extract_results(body)

      {
        source: "TMview",
        query: payload,
        total: extract_total(body, results),
        results: results.map { |record| normalize_record(record) }
      }
    end

    def extract_results(body)
      [
        body["results"],
        body["tradeMarks"],
        body.dig("data", "results"),
        body.dig("response", "docs")
      ].find { |value| value.is_a?(Array) } || []
    end

    def extract_total(body, results)
      body["total"] || body["totalResults"] || body["numFound"] || body.dig("response", "numFound") || results.length
    end

    def normalize_record(record)
      st13 = first_value(record, "ST13", "st13", "id")

      {
        id: st13,
        name: first_value(record, "tmName", "trademarkName", "name", "verbalElement", "markVerbalElementText"),
        office: first_value(record, "tmOffice", "office", "officeCode", "registrationOfficeCode"),
        status: first_value(record, "tmStatus", "status", "tradeMarkStatus", "markCurrentStatusCode"),
        owner: first_value(record, "ownerName", "applicantName", "holderName"),
        application_number: first_value(record, "applicationNumber", "appNumber"),
        registration_number: first_value(record, "registrationNumber", "regNumber"),
        application_date: first_value(record, "applicationDate", "applicationFilingDate"),
        nice_classes: normalize_classes(first_value(record, "niceClass", "niceClasses", "niceClassification")),
        source_url: st13.present? ? "https://www.tmdn.org/tmview/#/tmview/detail/#{st13}" : nil
      }.compact
    end

    def first_value(record, *keys)
      keys.lazy.map { |key| record[key] }.find(&:present?)
    end

    def normalize_classes(value)
      case value
      when Array
        value.map(&:to_s)
      when String
        value.split(/[,\s]+/).reject(&:blank?)
      else
        []
      end
    end
  end
end
