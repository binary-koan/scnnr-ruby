module Scnnr
  module Commands
    class HandleResponse
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def call
        case response
        when Net::HttpSuccess
          handle_recognition
        when Net::HTTPNotFound
          raise RecognitionNotFound, json_body
        when Net::HTTPUnprocessableEntity
          raise RequestFailed, json_body
        else
          raise UnexpectedError, response
        end
      end

      private

      def handle_recognition
        return recognition unless recognition.error?

        case recognition.error['type']
        when 'unexpected-content', 'bad-request'
          raise RequestFailed, recognition.error
        else
          raise RecognitionFailed, recognition
        end
      end

      def recognition
        @recognition ||= Concepts::Recognition.new(json_body)
      end

      def json_body
        @json_body ||= JSON.parse(response.body)
      end
    end
  end
end
