# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Zerocracy
# SPDX-License-Identifier: MIT

require 'faraday'
require_relative '../middleware'

# Faraday Middleware that monitors GitHub API rate limits.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2025 Zerocracy
# License:: MIT
class Fbe::Middleware::Quota < Faraday::Middleware
  # Constructor.
  #
  # @param [Object] app The Faraday app
  # @param [Loog] loog The logging facility
  # @param [Integer] pause Seconds to pause when rate limit is reached
  # @param [Integer] limit Maximum number of requests before checking rate limit
  # @param [Integer] rate Minimum remaining requests threshold
  def initialize(app, loog: Loog::NULL, pause: 60, limit: 100, rate: 5)
    super(app)
    @requests = 0
    @app = app
    raise 'The "loog" cannot be nil' if loog.nil?
    @loog = loog
    raise 'The "pause" cannot be nil' if pause.nil?
    raise 'The "pause" must be a positive integer' unless pause.positive?
    @pause = pause
    raise 'The "limit" cannot be nil' if limit.nil?
    raise 'The "limit" must be a positive integer' unless limit.positive?
    @limit = limit
    raise 'The "rate" cannot be nil' if rate.nil?
    raise 'The "rate" must be a positive integer' unless rate.positive?
    @rate = rate
  end

  # Process the request and handle rate limiting.
  #
  # @param [Faraday::Env] env The environment
  # @return [Faraday::Response] The response
  def call(env)
    @requests += 1
    response = @app.call(env)
    if out_of_limit?(env)
      @loog.info("Too much GitHub API quota consumed, pausing for #{@pause} seconds")
      sleep(@pause)
      @requests = 0
    end
    response
  end

  private

  # Check if we're approaching the rate limit.
  #
  # @param [Faraday::Env] env The environment
  # @return [Boolean] True if we should pause to avoid hitting rate limits
  def out_of_limit?(env)
    remaining = env.response_headers['x-ratelimit-remaining'].to_i
    (@requests % @limit).zero? && remaining < @rate
  end
end
