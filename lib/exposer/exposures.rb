module DryExposer
  class Exposures
    attr_reader :exposures

    def initialize
      @exposures = []
    end

    def add( key, content, **options )
      raise "Key already exists" if exposures.select { |exp| exp.key == key }.any?
      @exposures.push Exposure.new( key, content, **options )
    end

    def each
      exposures.each do |exposure|
        yield exposure
      end
    end

    def inject( start )
      exposures.inject( start ) do |result, exposure|
        yield result, exposure
      end
    end
    #    attr_reader :exposures
    #
    #    def initialize
    #      @exposures = {}
    #    end
    #
    #    def add( key, content, **options )
    #      exposures[ key ] = Exposure.new( key, content, **options )
    #    end
    #
    #    def import( name, exposure )
    #      exposures[ name ] = exposure
    #    end
    #
    #    def each
    #      exposures.each do |key, exposure|
    #        yield key, exposure
    #      end
    #    end
    #
    #    def inject( starter, &block )
    #      exposures.values.inject( starter, &block )
    #    end
    #  end
  end
end

