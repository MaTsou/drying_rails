###################################################
# class DryExposer::Base
# A base class to application wide exposers
module DryExposer
  # @abstract Subclasses will use +expose+ method only at class level
  #   and instances will use mainly +call+ method and eventually additive 
  #   private methods.
  class Base

    # class methods
    class << self
      # @api public
      #
      # provide a way to declare content to be available in views and 
      # automatically decorate returned objects with appropriate modules.
      #
      # These module names default to content name. Advice is made to name 
      # collections with a plural noun. For instance, :inputs key will lead
      # InputsPresenter to decorate collection and InputPresenter to decorate 
      # subitems.
      #
      # @param key [Symbol] name for the declared local variable
      #
      # @param args [Object] optional content for the key named local variable
      #
      # @param options [{with: Symbol, Array<Symbol>}] optional with: [ var, subitem ] named 
      #   argument to override default decorator names.
      #
      # @param block [Proc] optional block defining content.
      #
      # Remark : instance level methods are accessible only through block or 
      # callable args (see +content_c+ example).
      #
      # Important : all proc arguments have to be named argument ! They refer 
      # to +context+ keys (+context+ being given to +call+ method) or 
      # previously defined exposure.
      #
      # @example
      #   class Home < DryExposer
      #
      #     expose :content_a
      #     expose :content_b, 'stuff'
      #     expose :content_c, -> (id:) { my_method id }
      #     expose :content_d do |id:, content_b:|
      #       "id is #{id} and other_content is #{content_b}"
      #     end
      #     expose :inputs, [ "hello", "world" ]
      #     expose :entries, with: :things do
      #       (1..3).map { |i| "entry #{i}" }
      #     end
      #     expose :categories, with: [ :things, :another ] do
      #       (1..3).map { |i| "category #{i}" }
      #     end
      #
      #     private
      #
      #     def my_method( id )
      #       "hello world #{id}"
      #     end
      #   end
      def expose( key, *args, **options, &block )
        get_content( *args, **options, &block ).then do |raw_content|
          define_method( key ) { raw_content }
          exposures.add key, raw_content, **options
        end
      end

      # @api protected
      # @!visibility private
      def exposures
        @exposures ||= Exposures.new
      end

      private

      def get_content( *args, **options, &block )
        block_given? ? block : args.shift
      end

    end

    # @api public
    # @return [Hash] a hash of locals to be given to a view
    #
    # @example
    #   Home.new.call( content_a: 'stuff', id: 3 )
    #   # will return a hash :
    #   {
    #     content_a: 'stuff', # decorated by Presenters::ContentA module if exists
    #     content_b: 'stuff', # decorated by Presenters::ContentB module if exists
    #     content_c: "id is 3", # decorated by ...
    #     content_d: "id is 3 and other content is stuff", # decorated by ...
    #     inputs: [ "hello", "world" ], # decorated by Presenters::Inputs and 
    #       subitem decorated by Presenters::Input if exists
    #     entries: [...], # decorated with Presenters::Things and Presenters::Thing
    #     categories: [...], # decorated with Presenters::Things and 
    #       Presenters::Another
    #   }
    #
    # @param entity [Object] not used
    # @param context [Ustruct] a Ustruct object containing named parameters
    #
    def call( entity, context )
      kwargs = { context: context }.merge context.to_hash# all inclusive !
      exposures.inject( {} ) do |result, exposure|
        result.merge!( exposure.call( self, **kwargs.merge( result ) ) )
      end
    end

    private

    def exposures
      self.class.exposures
    end

  end
end

