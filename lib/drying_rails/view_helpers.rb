module DryingRails
  module ViewHelpers
    def component( component, *args, **options )
      ::DryingContainer["components.#{component}"].configure( self, **options )
    end
  end
end
