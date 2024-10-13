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
require 'loog'
require 'factbase'
require 'factbase/syntax'
require 'judges/options'
require_relative '../test__helper'
require_relative '../../lib/fbe/conclude'
require_relative '../../lib/fbe/fb'

# Test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024 Zerocracy
# License:: MIT
class TestConclude < Minitest::Test
  def test_with_defaults
    $fb = Factbase.new
    $global = {}
    $options = Judges::Options.new
    $loog = Loog::NULL
    $judge = ''
    Fbe.conclude do
      # nothing
    end
  end

  def test_draw
    fb = Factbase.new
    fb.insert.foo = 1
    fb.insert.bar = 2
    Fbe.conclude(fb:, judge: 'judge-one', loog: Loog::NULL, global: {}, options: Judges::Options.new) do
      on '(exists foo)'
      draw do |n, prev|
        n.sum = prev.foo + 1
        'something funny'
      end
    end
    f = fb.query('(exists sum)').each.to_a[0]
    assert_equal(2, f.sum)
    assert_equal('judge-one', f.what)
    assert_equal('something funny', f.details)
  end

  def test_consider
    fb = Factbase.new
    fb.insert.foo = 1
    options = Judges::Options.new
    Fbe.conclude(fb:, judge: 'issue-was-closed', loog: Loog::NULL, options:, global: {}) do
      on '(exists foo)'
      consider do |_prev|
        fb.insert.bar = 42
      end
    end
    f = fb.query('(exists bar)').each.to_a[0]
    assert_equal(42, f.bar)
  end

  def test_ignores_globals
    $fb = nil
    $loog = nil
    $options = nil
    $global = nil
    fb = Factbase.new
    fb.insert.foo = 1
    Fbe.conclude(fb:, judge: 'judge-xxx', loog: Loog::NULL, global: {}, options: Judges::Options.new) do
      on '(exists foo)'
      draw do |n, prev|
        n.sum = prev.foo + 1
        'something funny'
      end
    end
    assert_equal(2, fb.size)
  end
end
