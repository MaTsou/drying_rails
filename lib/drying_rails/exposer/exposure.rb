module DryExposer
  class Exposure
    attr_reader :key, :content, :decorator

    def initialize( key, content, **options )
      @key, @content = key, content
      @decorator = Decorator.new( key, options.fetch( :with, nil ) )
    end

    def call( exposer, **kwargs )
      { key => decorator.call( the_content( exposer, **kwargs ) ) }
    end

    private

    def callable?
      content.respond_to? :call
    end

    def the_content( exposer, **kwargs )
      return kwargs[ key ] if kwargs.has_key? key
      callable? ? get_content( exposer, get_args( **kwargs ) ) : content
    end

    def get_content( exposer, args )
      begin
        content.call( **args )
      rescue NameError => err
        err.receiver.define_singleton_method( err.name ) do |*args, **options|
          exposer.send( err.name, *args, **options )
        end
        content.call( **args )
      end
    end

    def get_args( **kwargs )
      content
        .parameters
        .map(&:pop)
        .inject( {} ) do |res, name|
          res.merge!( name => kwargs.fetch( name, nil ) ) || res
        end
    end
  end
end

