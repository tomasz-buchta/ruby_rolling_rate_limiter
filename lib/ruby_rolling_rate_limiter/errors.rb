class RubyRollingRateLimiter
  module Errors
    class RedisNotFound < StandardError; end
    class ArgumentInvalid < StandardError; end
  end
end