module Scnnr
  module Commands
    class PerformRequest
      ENDPOINT_BASE = 'https://api.scnnr.cubki.jp'

      attr_reader :config, :endpoint, :http_method, :timeout, :json_body, :stream_body, :request

      def initialize(config:, endpoint:, method:, timeout:, json_body: nil, stream_body: nil)
        @config = config
        @endpoint = endpoint
        @http_method = method
        @json_body = json_body
        @stream_body = stream_body
      end

      def call
        build_request
        add_json_body if json_body
        add_stream_body if stream_body
        add_api_key
        run_request
      end

      private

      def build_request
        @request = request_class.new(uri.request_uri)
      end

      def add_json_body
        req['Content-Type'] = 'application/json'
        req.body = json_body
      end

      def add_stream_body
        req['Content-Type'] = 'application/octet-stream'
        req['Transfer-Encoding'] = 'chunked'
        req.body_stream = stream_body
      end

      def add_api_key
        request['x-api-key'] = config.api_key if config.api_key
      end

      def run_request
        Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl?) do |http|
          config.logger&.info("Started #{http_method.to_s.upcase} #{uri}")
          http.request(request)
        end
      end

      def request_class
        case http_method&.intern
        when :get
          Net::Http::Get
        when :post
          Net::Http::Post
        else
          raise NotImplementedError
        end
      end

      def use_ssl?
        uri.scheme == 'https'
      end

      def uri
        URI.parse("#{ENDPOINT_BASE}/#{config.api_version}/#{endpoint}?timeout=#{timeout}")
      end
    end
  end
end
