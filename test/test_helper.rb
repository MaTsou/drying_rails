# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/assertions'
require 'minitest/spec'

module Minitest
  module Assertions
    #
    #  Fails unless +expected and +actual have the same items.
    #
    def assert_has_ancestor(expected, actual)
      assert(
        ancestor?(expected, actual),
        "Expected #{actual.inspect} to have #{expected.inspect} ancestor"
      )
    end

    #
    #  Fails if +expected and +actual have the same items.
    #
    def refute_has_ancestor(expected, actual)
      refute(
        ancestor?(expected, actual),
        "Expected #{actual.inspect} to not have #{expected.inspect} ancestor"
      )
    end

    private

    def ancestor?(expected, actual)
      actual.singleton_class.ancestors.include? expected
    end
  end
end

module Minitest
  module Expectations
    #
    #  Fails unless the subject and parameter have the same items
    #
    Enumerable.infect_an_assertion :assert_has_ancestor, :must_have_ancestor

    #
    #  Fails if the subject and parameter have the same items
    #
    Enumerable.infect_an_assertion :refute_has_ancestor, :wont_have_ancestor
  end
end
