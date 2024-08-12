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

require 'minitest/autorun'
require 'judges/options'
require 'webmock/minitest'
require 'loog'
require_relative '../../lib/fbe/gh_graphql'

# Test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024 Zerocracy
# License:: MIT
class TestGHGraphQL < Minitest::Test
  def test_simple_use
    WebMock.disable_net_connect!
    global = {}
    options = Judges::Options.new({ 'testing' => true })
    Fbe.gh_graphql(options:, loog: Loog::NULL, global:)
  end

  def test_use_with_global_variables
    WebMock.disable_net_connect!
    $global = {}
    $options = Judges::Options.new({ 'testing' => true })
    $loog = Loog::NULL
    Fbe.gh_graphql
  end

  def test_gets_resolved_conversations
    skip
    WebMock.disable_net_connect!
    global = {}
    options = Judges::Options.new('github_token' => 'token')
    g = Fbe.gh_graphql(options:, loog: Loog::NULL, global:)
    result = g.resolved_converstations('zerocracy', 'baza', 172)
    assert_equal(1, result.count)
  end
end
