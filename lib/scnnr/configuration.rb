module Scnnr
  class Configuration
    attr_reader :api_key, :api_version, :timer, :logger

    def initialize(api_key:, api_version:, timeout:, max_timeout:, logger: nil)
      @api_key = api_key
      @api_version = api_version
      @timer = Timer.new(timeout: timeout, per_iteration_timeout: max_timeout)
      @logger = logger || Logger.new(STDOUT, level: :info)
    end
  end
end
