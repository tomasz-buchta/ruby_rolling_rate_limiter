# RubyRollingRateLimiter

Often Redis is used for rate limiting purposes.
Usually the rate limit packages available count how many times something happens on a certain second or a certain minute. When the clock ticks to the next minute, rate limit counter is reset back to the zero. 

This might be problematic if you are looking to limit rates where hits per integration time window is very low. 
If you are looking to limit to the five hits per minute, in one time window you get just one hit and six in another, even though the average over two minutes is 3.5.

This package allows you to implement a correct rolling window of threshold that's backed by ATOMIC storage in Redis meaning you can use this implementation across multiple machines and processes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_rolling_rate_limiter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_rolling_rate_limiter

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruby_rolling_rate_limiter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

