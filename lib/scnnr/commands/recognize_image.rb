module Scnnr
  module Commands
    class RecognizeImage
      attr_reader :image, :config, :recognition

      def initialize(image, config)
        @image = image
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
          endpoint: '/recognitions',
          method: :post,
          timeout: request_timeout,
          stream_body: image
        ).call

        @recognition = HandleResponse.new(response).call
      end

      def poll_for_recognition
        @recognition = FetchRecognition.new(recognition.id, config).call
      end
    end
  end
end
