ActiveSupport.on_load( :action_controller ) do
  include DryingRails::ParamsManager
  include DryingRails::ControllerHelpers
end
