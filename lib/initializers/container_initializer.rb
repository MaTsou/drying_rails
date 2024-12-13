require 'dry/system'
require 'thy_result'

class ::DryingContainer < Dry::System::Container
  configure do |config|
    config.root = Rails.root
    config.component_dirs.add 'app/drying'
  end
  self.register 'result', ThyResult
  self.finalize! if Rails.env.production?
end
::Deps = DryingContainer.injector

