module Scnnr
  module Commands
    class FetchRecognition
      attr_reader :id, :config, :recognition

      def initialize(id, config)
        @id = id
        @config = config
      end

      def call
        request_recognition until done?
        recognition
      end

      private

      def request_recognition
        request_timeout = config.timer.advance!
        response = PerformRequest.new(
          config: config,
          endpoint: "/recognitions/#{id}",
          method: :get,
          timeout: request_timeout,
          stream_body: image
        ).call

        @recognition = HandleResponse.new(response).call
      end

      def done?
        config.timer.expired? || recognition.finished?
      end
    end
  end
end
