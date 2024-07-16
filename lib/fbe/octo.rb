# frozen_string_literal: true

# MIT License
#
# Copyright (c) 2024 Zerocracy
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'loog'
require 'decoor'
require 'obk'
require 'octokit'
require 'verbose'
require 'faraday/http_cache'
require 'faraday/retry'
require_relative '../fbe'

def Fbe.octo(options: $options, global: $global, loog: $loog)
  raise 'The $global is not set' if global.nil?
  global[:octo] ||= begin
    if options.testing.nil?
      o = Octokit::Client.new
      token = options.github_token
      loog.debug("The 'github_token' option is not provided") if token.nil?
      token = ENV.fetch('GITHUB_TOKEN', nil) if token.nil?
      loog.debug("The 'GITHUB_TOKEN' environment variable is not set") if token.nil?
      if token.nil?
        loog.warn('Accessing GitHub API without a token!')
      elsif token.empty?
        loog.warn('The GitHub API token is an empty string, won\'t use it')
      else
        o = Octokit::Client.new(access_token: token)
        loog.info("Accessing GitHub API with a token (#{token.length} chars)")
      end
      o.auto_paginate = true
      o.per_page = 100
      o.connection_options = {
        request: {
          open_timeout: 15,
          timeout: 15
        }
      }
      stack = Faraday::RackBuilder.new do |builder|
        builder.use(Faraday::Retry::Middleware)
        builder.use(Faraday::HttpCache, serializer: Marshal, shared_cache: false)
        builder.use(Octokit::Response::RaiseError)
        builder.adapter(Faraday.default_adapter)
      end
      o.middleware = stack
      o = Verbose.new(o, log: loog)
    else
      loog.debug('The connection to GitHub API is mocked')
      o = Fbe::FakeOctokit.new
    end
    decoor(o, loog:) do
      def off_quota
        left = @origin.rate_limit.remaining
        if left < 5
          @loog.info("To much GitHub API quota consumed already (remaining=#{left}), stopping")
          true
        else
          false
        end
      end

      def user_name_by_id(id)
        json = @origin.user(id)
        name = json[:login]
        @loog.debug("GitHub user ##{id} has a name: @#{name}")
        name
      end

      def repo_id_by_name(name)
        json = @origin.repository(name)
        id = json[:id]
        @loog.debug("GitHub repository #{name} has an ID: ##{id}")
        id
      end

      def repo_name_by_id(id)
        json = @origin.repository(id)
        name = json[:full_name]
        @loog.debug("GitHub repository ##{id} has a name: #{name}")
        name
      end
    end
  end
end

# Fake GitHub client, for tests.
class Fbe::FakeOctokit
  def random_time
    Time.now - rand(10_000)
  end

  def name_to_number(name)
    return name unless name.is_a?(String)
    name.chars.map(&:ord).inject(0, :+)
  end

  def rate_limit
    o = Object.new
    def o.remaining
      100
    end
    o
  end

  def repositories(_user = nil)
    [
      {
        name: 'judges',
        full_name: 'yegor256/judges',
        id: 444
      }
    ]
  end

  def user(name)
    {
      id: 444,
      login: 'yegor256',
      type: name == 29_139_614 ? 'Bot' : 'User'
    }
  end

  def repository(name)
    {
      id: name_to_number(name),
      full_name: name.is_a?(Integer) ? 'yegor256/test' : name
    }
  end

  def add_comment(_repo, _issue, _text)
    {
      id: 42
    }
  end

  def search_issues(_query, _options = {})
    {
      items: [
        {
          number: 42,
          labels: [
            {
              name: 'bug'
            }
          ]
        }
      ]
    }
  end

  def issue_timeline(_repo, _issue, _options = {})
    [
      {
        actor: {
          id: 888,
          login: 'torvalds'
        },
        repository: {
          id: name_to_number('yegor256/judges'),
          full_name: 'yegor256/judges'
        },
        event: 'renamed',
        rename: {
          from: 'before',
          to: 'after'
        },
        created_at: random_time
      },
      {
        actor: {
          id: 888,
          login: 'torvalds'
        },
        repository: {
          id: name_to_number('yegor256/judges'),
          full_name: 'yegor256/judges'
        },
        event: 'labeled',
        label: {
          name: 'bug'
        },
        created_at: random_time
      }
    ]
  end

  def repository_events(repo, _options = {})
    [
      {
        id: '123',
        type: 'PushEvent',
        repo: {
          id: name_to_number(repo),
          name: repo,
          url: "https://api.github.com/repos/#{repo}"
        },
        payload: {
          push_id: 42,
          ref: 'refs/heads/master',
          size: 1,
          distinct_size: 0,
          head: 'b7089c51cc2526a0d2619d35379f921d53c72731',
          before: '12d3bff1a55bad50ee2e8f29ade7f1c1e07bb025'
        },
        actor: {
          id: 888,
          login: 'torvalds',
          display_login: 'torvalds'
        },
        created_at: random_time,
        public: true
      },
      {
        id: '124',
        type: 'IssuesEvent',
        repo: {
          id: name_to_number(repo),
          name: repo,
          url: "https://api.github.com/repos/#{repo}"
        },
        payload: {
          action: 'closed',
          issue: {
            number: 42
          }
        },
        actor: {
          id: 888,
          login: 'torvalds',
          display_login: 'torvalds'
        },
        created_at: random_time,
        public: true
      },
      {
        id: '125',
        type: 'IssuesEvent',
        repo: {
          id: name_to_number(repo),
          name: repo,
          url: "https://api.github.com/repos/#{repo}"
        },
        payload: {
          action: 'opened',
          issue: {
            number: 42
          }
        },
        actor: {
          id: 888,
          login: 'torvalds',
          display_login: 'torvalds'
        },
        created_at: random_time,
        public: true
      }
    ]
  end
end
