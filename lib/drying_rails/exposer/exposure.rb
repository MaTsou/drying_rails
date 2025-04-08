# frozen_string_literal: true

module DryExposer
  # Exposure class
  class Exposure
    attr_reader :key, :content, :decorator

    def initialize(key, content, **options)
      @key = key
      @content = content
      @decorator = Decorator.new key, options.fetch(:with, nil)
    end

    def call(exposer, **kwargs)
      { key => decorator.call(the_content(exposer, **kwargs)) }
    end

    private

    def callable?
      content.respond_to? :call
    end

    def the_content(exposer, **kwargs)
      return kwargs[key] if kwargs.key? key

      callable? ? get_content(exposer, get_args(**kwargs)) : content
    end

    def get_content(exposer, args)
      content.call(**args)
    rescue NameError => e
      e.receiver.define_singleton_method(e.name) do |*the_args, **options|
        exposer.send(e.name, *the_args, **options)
      end
      content.call(**args)
    end

    def get_args(**kwargs)
      content
        .parameters
        .map(&:pop)
        .inject({}) do |res, name|
          res.merge!(name => kwargs.fetch(name, nil)) || res
        end
    end
  end
end
