# frozen_string_literal: true

# MIT License
#
# Copyright (c) 2024-2025 Zerocracy
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
require 'factbase'
require_relative '../test__helper'
require_relative '../../lib/fbe/pmp'

# Test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2025 Zerocracy
# License:: MIT
class TestPmp < Minitest::Test
  def test_defaults
    $fb = Factbase.new
    $global = {}
    $options = Judges::Options.new
    f = Fbe.fb(loog: Loog::NULL).insert
    f.what = 'pmp'
    f.area = 'hr'
    f.days_to_reward = 55
    $loog = Loog::NULL
    assert_equal(55, Fbe.pmp(loog: Loog::NULL).hr.days_to_reward)
  end

  def test_fail_on_wrong_area
    $global = {}
    $loog = Loog::NULL
    assert_raises { Fbe.pmp(Factbase.new, loog: Loog::NULL).something }
  end
end
