# frozen_string_literal: true

ActiveSupport.on_load(:action_view) do
  include DryingRails::ViewHelpers
end
