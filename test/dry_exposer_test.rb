# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/initializers/exposer_initializer'
require 'ustruct'

SUFFIX = 'I am there'
BUDGET = Ustruct.new(id: 123_456)
def given
  { b: 'bonjour le monde' }
end

def absolute
  { a: 'Hello world' }
end

module Presenters
  module Given; end
  module Absolute; end
  module AbsoluteLists; end
  module AbsoluteList; end
end

class TestExposer < DryExposer::Base
  # include Deps[the_called: 'actions.budgets.read_query']
  the_called = ->(_id) { BUDGET } # faking call

  expose :given, 'fake'
  expose :absolute, absolute, with: :absolute
  expose :absolute_callable, -> { absolute }
  expose :absolute_callable_with_arg, ->(id:) { my_method id }
  expose :relative do |id:|
    my_method id
  end
  expose :relative_callable do |context:|
    the_called.call(context.id)
  end
  expose :other_relative_callable do |id:|
    the_called.call(id)
  end
  expose :absolute_lists, [absolute]
  expose :with_absolute_lists, [absolute], with: %i[given absolute]
  expose :use_other do |relative:|
    [relative, SUFFIX].join ' '
  end

  def my_method(id)
    [absolute, id].join
  end
end

describe DryExposer do
  describe 'A unique test' do
    it 'works' do
      @budget = BUDGET
      exposer = TestExposer.new
      expected = {
        given: given,
        absolute: absolute,
        absolute_callable: absolute,
        absolute_callable_with_arg: [absolute, @budget.id].join,
        relative: [absolute, @budget.id].join,
        relative_callable: @budget,
        other_relative_callable: @budget,
        absolute_lists: [absolute],
        with_absolute_lists: [absolute],
        use_other: [[absolute, @budget.id].join, SUFFIX].join(' ')
      }

      result = exposer.call(
        'entity', Ustruct.new(given: given, id: @budget.id)
      )

      # expected results
      _(result).must_equal expected

      # expected decoration : result is object
      _(result[:given]).must_have_ancestor Presenters::Given

      # expected decoration : result is object, with: option used
      _(result[:absolute]).must_have_ancestor Presenters::Absolute

      # expected decoration : result is Array of objects
      _(result[:absolute_lists]).must_have_ancestor Presenters::AbsoluteLists
      _(result[:absolute_lists].first).must_have_ancestor Presenters::AbsoluteList

      # expected decoration : result is Array of objects, with: option used
      _(result[:with_absolute_lists]).must_have_ancestor Presenters::Given
      _(result[:with_absolute_lists].first).must_have_ancestor Presenters::Absolute
    end
  end
end
