# frozen_string_literal: true

module DryExposer
  # Fallback is a default decorator aliasing 'the_myvar' to 'myvar'
  module Fallback
    def method_missing(name, *args)
      return super unless name.to_s =~ /^the_/

      send name.to_s.gsub('the_', '').to_sym, *args
    end

    def respond_to_missing?(name, include_private = false)
      name.to_s =~ /^the_/ || super
    end
  end

  # Decorator module.. to be commented.
  class Decorator
    attr_reader :decorators

    # Singular module.. to be commented.
    module Singular
      # needed when testing outside a Rails context
      def singularize
        gsub(/s$/, '')
      end
    end

    def initialize(key, args)
      @decorators = case args
                    when nil
                      do_singularize key
                    when Array
                      args
                    else
                      do_singularize args
                    end.map { |str| to_presenter str }
    end

    def call(item)
      item
        .extend(*item_decorator)
        .tap do |it|
          if it.respond_to?(:each)
            mod = subitem_decorator
            it.each { |sub_item| sub_item.extend(*mod) }
          end
        end
    end

    private

    def do_singularize(key)
      k = key.to_s
      k.extend Singular unless k.respond_to? :singularize
      [k, k.singularize]
    end

    def item_decorator
      compose_decorators decorators.first
    end

    def subitem_decorator
      compose_decorators decorators.last
    end

    def compose_decorators(deco)
      deco ? default_decorator << deco : default_decorator
    end

    def default_decorator
      [Fallback]
    end

    def to_presenter(str)
      Object.const_get "Presenters::#{to_const str}"
    rescue NameError
      nil
    end

    def to_const(str)
      str.to_s.split('_').map(&:capitalize).join
    end
  end
end
