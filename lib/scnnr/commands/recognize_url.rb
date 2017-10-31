module Scnnr
  module Commands
    class RecognizeUrl
      attr_reader :url, :config, :recognition

      def initialize(url, config)
        @url = url
        @config = config
      end

      def call
        request_recognition
        poll_for_recognition unless config.timer.expired?
        recognition
      end

      private

      def request_recognition
        request_timeout = config.timer.advance!
        response = PerformRequest.new(
          config: config,
          endpoint: '/remote/recognitions',
          method: :post,
          timeout: request_timeout,
          json_body: { url: url }
        ).call

        @recognition = HandleResponse.new(response).call
      end

      def poll_for_recognition
        @recognition = FetchRecognition.new(recognition.id, config).call
      end
    end
  end
end
