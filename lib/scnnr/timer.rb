module Scnnr
  class Timer
    attr_reader :timeout, :per_iteration_timeout

    def initialize(timeout:, per_iteration_timeout:)
      @timeout = timeout
      @per_iteration_timeout = per_iteration_timeout
    end

    def advance!
      current_timeout = [timeout, per_iteration_timeout].min
      @timeout = timeout - current_timeout

      current_timeout
    end

    def expired?
      !timeout.positive?
    end
  end
end
