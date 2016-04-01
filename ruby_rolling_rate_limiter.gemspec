# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_rolling_rate_limiter/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby_rolling_rate_limiter"
  spec.version       = RubyRollingRateLimiter::VERSION
  spec.authors       = ["Karl Kloppenborg"]
  spec.email         = ["karl@logicsaas.com"]

  spec.summary       = %q{Ruby Rolling Rate Limiter provides a redis backed rolling window rate limiting service}
  spec.description   = %q{Often Redis is used for rate limiting purposes. Usually the rate limit packages available count how many times something happens on a certain second or a certain minute. When the clock ticks to the next minute, rate limit counter is reset back to the zero. This might be problematic if you are looking to limit rates where hits per integration time window is very low. If you are looking to limit to the five hits per minute, in one time window you get just one hit and six in another, even though the average over two minutes is 3.5. This package allows you to implement a correct rolling window of threshold that's backed by ATOMIC storage in Redis meaning you can use this implementation across multiple machines and processes.}
  spec.homepage      = "https://github.com/logicsaas/ruby_rolling_rate_limiter"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "bump"

  spec.add_runtime_dependency "redis", "~> 3.2"
  spec.add_runtime_dependency "mlanett-redis-lock"
end
