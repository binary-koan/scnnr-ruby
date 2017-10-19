# frozen_string_literal: true

module Scnnr
  class PollingManager
    attr_reader :remaining_timeout, :max_timeout, :stop_condition, :last_result

    def initialize(timeout, max_timeout:)
      @max_timeout = max_timeout

      case timeout
      when Integer, Float::INFINITY then @remaining_timeout = timeout
      else
        raise ArgumentError, "timeout must be Integer or Float::INFINITY, but given: #{timeout}"
      end
    end

    def stop_when(&condition)
      @stop_condition = condition
      self
    end

    def once(&block)
      poll(&block) if continue_polling?
      self
    end

    def repeat(&block)
      poll(&block) while continue_polling?
      self
    end

    def started?
      !last_result.nil?
    end

    def successful?
      started? && (!stop_condition || stop_condition.call(last_result))
    end

    def timed_out?
      remaining_timeout <= 0
    end

    private

    def continue_polling?
      # We always want to do at least one iteration
      return true unless started?

      !timed_out? && !successful?
    end

    def poll
      current_timeout = [remaining_timeout, max_timeout].min
      @remaining_timeout -= current_timeout
      @last_result = yield current_timeout, last_result

      #TODO: Yucky way to ensure started? is true
      # Technically this isn't needed right now because we return a non-nil recognition, but it's a potential trap ...
      @last_result ||= false
    end
  end
end
