module DryExposer
  module Fallback
    def method_missing( name, *args )
      return super unless name.to_s =~ /^the_/
      send( name.to_s.gsub( "the_", "" ).to_sym, *args )
    end
  end

  class Decorator
    attr_reader :decorators

    def initialize( key, args )
      @decorators = case args
                    when nil
                      [ key.to_s, key.to_s.singularize ]
                    when Array
                      args
                    else
                      [ args.to_s, args.to_s.singularize ]
                    end.map { |str| to_presenter( str ) }
    end

    def call( item )
      item
        .extend( *item_decorator )
        .tap do |it|
          if it.respond_to?( :each )
            mod = subitem_decorator
            it.each { |sub_item| sub_item.extend *mod }
          end
        end
    end

    private

    def item_decorator
      compose_decorators( decorators.first )
    end

    def subitem_decorator
      compose_decorators( decorators.last )
    end

    def compose_decorators( deco )
      deco ? default_decorator << deco : default_decorator
    end

    def default_decorator
      [ Fallback ]
    end

    def to_presenter( str )
      begin
        Object.const_get( "Presenters::#{to_const( str )}" )
      rescue
        nil
      end
    end

    def to_const( str )
      str.to_s.split('_').map(&:capitalize).join
    end
  end
end

