# frozen_string_literal: true

module Scnnr
  class Client
    require 'net/http'
    require 'json'

    ENDPOINT_BASE = 'https://api.scnnr.cubki.jp'
    API_MAX_TIMEOUT = 25

    def initialize
      yield(self.config) if block_given?
    end

    def config
      @config ||= Configuration.new
    end

    def recognize_image(image, options = {})
      options = merge_options(options)
      poll_while_queued(options).
        once { |timeout| request_image_recognition(image, options.merge(timeout: timeout)) }.
        repeat { |timeout, recognition| fetch_recognition(recognition.id, options.merge(timeout: timeout)) }
    end

    def recognize_url(url, options = {})
      options = merge_options(options)
      poll_while_queued(options).
        once { |timeout| request_url_recognition(url, options.merge(timeout: timeout)) }.
        repeat { |timeout, recognition| fetch_recognition(recognition.id, options.merge(timeout: timeout)) }
    end

    def fetch(recognition_id, options = {})
      options = merge_options(options)
      poll_while_queued(options).
        repeat { |timeout| fetch_recognition(recognition_id, options.merge(timeout: timeout)) }
    end

    private

    def merge_options(options = {})
      self.config.to_h.merge(options)
    end

    def construct_uri(path, options = {})
      options = merge_options(options)
      URI.parse("#{ENDPOINT_BASE}/#{options[:api_version]}/#{path}?timeout=#{options[:timeout]}")
    end

    def get_connection(uri, options = {})
      Connection.new(uri, :get, nil, options[:logger])
    end

    def post_connection(uri, options = {})
      Connection.new(uri, :post, options[:api_key], options[:logger])
    end

    def poll_while_queued(options)
      PollingManager.new(options[:timeout], max_timeout: API_MAX_TIMEOUT).
        stop_when { |recognition| !recognition.queued? }
    end

    def request_image_recognition(image, options)
      uri = construct_uri('recognitions', options)
      response = post_connection(uri, options).send_stream(image)
      handle_response(response, options)
    end

    def request_url_recognition(url, options)
      uri = construct_uri('remote/recognitions', options)
      response = post_connection(uri, options).send_json({ url: url })
      handle_response(response, options)
    end

    def fetch_recognition(recognition_id, options = {})
      options = merge_options(options)
      uri = construct_uri("recognitions/#{recognition_id}", options)
      response = get_connection(uri, options).send_request
      handle_response(response, options)
    end

    def handle_response(response, options = {})
      response = Response.new(response, options[:timeout].positive?)
      response.build_recognition
    end
  end
end
