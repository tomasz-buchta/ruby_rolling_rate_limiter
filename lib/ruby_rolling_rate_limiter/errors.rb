class RubyRollingRateLimiter
  module Errors
    class RedisNotFound < StandardError; end
    class ArgumentInvalid < StandardError; end
    class LockWaiting < StandardError; end
    class MaxRetryReachedOnLockAcquire < StandardError; end
  end
end