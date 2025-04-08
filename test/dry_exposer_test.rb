require_relative 'test_helper.rb'
require_relative '../lib/initializers/exposer_initializer'
require 'ustruct'

describe DryExposer do
  ABSOLUTE = "Hello world"
  SUFFIX = "I am there"
  BUDGET = Ustruct.new( id: 123456 )

  before do

    module Presenters
      module Presenters::Given; end
      module Presenters::Absolute; end
      module Presenters::AbsoluteLists; end
      module Presenters::AbsoluteList; end
    end


    class TestExposer < DryExposer::Base
      #include Deps[ the_called: 'actions.budgets.read_query' ]
      the_called = -> ( id ) { BUDGET } # faking call

      expose :given, 'fake'
      expose :absolute, ABSOLUTE, with: :given
      expose :absolute_callable, -> { ABSOLUTE }
      expose :absolute_callable_with_arg, -> (id:) { my_method id }
      expose :relative do |id:|
        my_method id
      end
      expose :relative_callable do |context:|
        the_called.call( context.id )
      end
      expose :other_relative_callable do |id:|
        the_called.call( id )
      end
      expose :absolute_lists, [ ABSOLUTE ]
      expose :with_absolute_lists, [ ABSOLUTE ], with: [ :given, :absolute ]
      expose :use_other do |relative:|
        [ relative, SUFFIX ].join ' '
      end

      def my_method( id )
        [ ABSOLUTE, id ].join
      end
    end
  end

  describe "A unique test" do

    it 'works' do
      @budget = BUDGET
      exposer = TestExposer.new
      expected = {
        given: ABSOLUTE,
        absolute: ABSOLUTE,
        absolute_callable: ABSOLUTE,
        absolute_callable_with_arg: [ABSOLUTE, @budget.id].join,
        relative: [ABSOLUTE, @budget.id].join,
        relative_callable: @budget,
        other_relative_callable: @budget,
        absolute_lists: [ ABSOLUTE ],
        with_absolute_lists: [ ABSOLUTE ],
        use_other: [ [ABSOLUTE, @budget.id].join, SUFFIX ].join( ' ' )
      }

      result = exposer.call(
        "entity", Ustruct.new( given: ABSOLUTE, id: @budget.id )
      )

      # expected results
      _( result ).must_equal expected

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
