# frozen_string_literal: true

module DryExposer
  # exposure class
  class Exposures
    attr_reader :exposures

    def initialize
      @exposures = []
    end

    def add(key, content, **options)
      raise 'Key already exists' if exposures.any? { |exp| exp.key == key }

      @exposures.push Exposure.new(key, content, **options)
    end

    def each(&block)
      exposures.each(&block)
    end

    def inject(start, &block)
      exposures.inject(start, &block)
    end
    #    attr_reader :exposures
    #
    #    def initialize
    #      @exposures = {}
    #    end
    #
    #    def add(key, content, **options)
    #      exposures[key] = Exposure.new(key, content, **options)
    #    end
    #
    #    def import(name, exposure)
    #      exposures[name] = exposure
    #    end
    #
    #    def each
    #      exposures.each do |key, exposure|
    #        yield key, exposure
    #      end
    #    end
    #
    #    def inject(starter, &block)
    #      exposures.values.inject(starter, &block)
    #    end
    #  end
  end
end
