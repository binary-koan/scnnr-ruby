module Scnnr
  class Client
    BASE_OPTIONS = { max_timeout: 25 }

    attr_reader :client_options

    def initialize(client_options)
      @client_options = client_options
    end

    def recognize_image(image, **options)
      Commands::RecognizeImage.new(image, build_config(options)).call
    end

    def recognize_url(url, **options)
      Commands::RecognizeUrl.new(url, build_config(options)).call
    end

    def fetch(recognition_id, **options)
      Commands::FetchRecognition.new(recognition_id, build_config(options)).call
    end

    private

    def build_config(options)
      Configuration.new(BASE_OPTIONS.merge(client_options).merge(options))
    end
  end
end
