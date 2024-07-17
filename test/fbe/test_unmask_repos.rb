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
require 'loog'
require_relative '../test__helper'
require_relative '../../lib/fbe/unmask_repos'

# Test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024 Zerocracy
# License:: MIT
class TestUnmaskRepos < Minitest::Test
  def test_simple_use
    opts = Judges::Options.new(
      {
        'testing' => true,
        'repositories' => 'yegor256/tacit,zerocracy/*,-zerocracy/judges-action'
      }
    )
    assert(Fbe.unmask_repos(options: opts, global: {}, loog: Loog::NULL).size.positive?)
  end

  def test_live_usage
    skip('Run it only manually, since it touches GitHub API')
    Judges::Options.new(
      {
        'repositories' => 'zerocracy/*,-zerocracy/judges-action'
      }
    )
    list = Fbe.unmask_repos(options: opts, global: {}, loog: Loog::NULL)
    assert(list.size.positive?)
    assert(list.include?('zerocracy/pages-action'))
    assert(!list.include?('zerocracy/judges-action'))
  end
end
