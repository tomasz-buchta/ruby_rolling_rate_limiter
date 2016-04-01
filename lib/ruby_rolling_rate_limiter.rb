require "ruby_rolling_rate_limiter/version"
require "ruby_rolling_rate_limiter/errors"
require "redis"
require 'redis-lock'
require "date"

class RubyRollingRateLimiter
  # Your code goes here...
  attr_reader :current_error

  def initialize(limiter_identifier, interval_in_seconds, max_calls_per_interval, min_distance_between_calls_in_seconds = 1, redis_connection = $redis)
    @limiter_identifier = limiter_identifier
    @interval_in_seconds = interval_in_seconds
    @max_calls_per_interval = max_calls_per_interval
    @min_distance_between_calls_in_seconds = min_distance_between_calls_in_seconds
    @redis_connection = redis_connection
    
    #Check to ensure args are good.
    validate_arguments

    # Check Redis is there
    check_redis_is_available

  end


  def set_call_identifier(id)
    raise Errors::ArgumentInvalid, "The id must be a string or number with length greater than zero" unless id.length > 0
    @id = id
  end

  def can_call_proceed?(call_size = 1)
    if call_size > @max_calls_per_interval
      @current_error = {code: 0, result: false, error: "Call size too big. Max calls in rolling window is: #{@max_calls_per_interval}. Increase your max_calls_per_interval or decrease your call_size", retry_in: 0}
      return false
    end
    results = false
    now = DateTime.now.strftime('%s%6N').to_i # Time since EPOC in microseconds.
    interval = @interval_in_seconds * 1000 * 1000 # Inteval in microseconds

    key = "#{self.class.name}-#{@limiter_identifier}-#{@id}"
    
    clear_before = now - interval
    # Begin multi redis
    @redis_connection.lock("#{key}-lock") do |lock|
      @redis_connection.multi
      @redis_connection.zremrangebyscore(key, 0, clear_before.to_s)
      @redis_connection.zrange(key, 0, -1)
      cur = @redis_connection.exec

      if (cur[1].count <= @max_calls_per_interval) && ((cur[1].count+call_size) <= @max_calls_per_interval) && ((@min_distance_between_calls_in_seconds * 1000 * 1000) && (now - cur[1].last.to_i) > (@min_distance_between_calls_in_seconds * 1000 * 1000))
        @redis_connection.multi
        @redis_connection.zrange(key, 0, -1)
        call_size.times do 
          @redis_connection.zadd(key, now.to_s, now.to_s)
        end
        @redis_connection.expire(key, @interval_in_seconds)
        results = @redis_connection.exec
      else
        results = [cur[1]]
      end
    end
    if results
      call_set = results[0]
      too_many_in_interval = call_set.count >= @max_calls_per_interval
      time_since_last_request = (@min_distance_between_calls_in_seconds * 1000 * 1000) && (now - call_set.last.to_i)

      if too_many_in_interval
        @current_error = {code: 1, result: false, error: "Too many requests", retry_in: (call_set.first.to_i - now + interval) / 1000 / 1000, retry_in_micro: (call_set.first.to_i - now + interval)}
        return false
      elsif (call_set.count+call_size) > @max_calls_per_interval
        @current_error = {code: 2, result: false, error: "Call Size too big for available access, trying to make #{call_size} with only #{call_set.count} calls available in window", retry_in: (call_set.first.to_i - now + interval) / 1000 / 1000, retry_in_micro: (call_set.first.to_i - now + interval)}
        return false
      elsif time_since_last_request < (@min_distance_between_calls_in_seconds * 1000 * 1000)
        @current_error = {code: 3, result: false, error: "Attempting to thrash faster than the minimal distance between calls", retry_in: @min_distance_between_calls_in_seconds, retry_in_micro: (@min_distance_between_calls_in_seconds * 1000 * 1000)}
        return false
      end
      return true
    end
    return false
  end

  private
  def validate_arguments
    raise Errors::ArgumentInvalid, "limiter_identifier argument must be 1 or more characters long" unless @limiter_identifier.length > 0
    raise Errors::ArgumentInvalid, "interval_in_seconds argument must be an integer, this is specified in seconds" unless @interval_in_seconds.is_a? Integer and @interval_in_seconds > 0
    raise Errors::ArgumentInvalid, "max_calls_per_interval argument must be an integer, this is the amount of calls that can be made during the rolling window." unless @max_calls_per_interval.is_a? Integer and @max_calls_per_interval > 0
    raise Errors::ArgumentInvalid, "min_distance_between_calls_in_seconds argument must be an integer, this is the buffer between each call during the rolling window" unless @min_distance_between_calls_in_seconds.is_a? Integer and @min_distance_between_calls_in_seconds > 0
  end

  #
  # Checks to ensure redis is present and available,
  def check_redis_is_available
    raise Errors::RedisNotFound, "Unable to find redis connection, either declare a global $redis connection or add the connection to the last argument on #{self.class.name} initializer" unless @redis_connection.is_a? Object and @redis_connection.class == Redis
  end
end