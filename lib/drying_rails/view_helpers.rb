# frozen_string_literal: true

module DryingRails
  # view helpers module
  module ViewHelpers
    def component(component, *_args, **options)
      ::DryingContainer["components.#{component}"].configure(self, **options)
    end
  end
end
