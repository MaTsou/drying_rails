ActiveSupport.on_load( :active_record ) do
  extend DryingRails::ModelHelpers
end

