# frozen_string_literal: true

require 'ustruct'
require_relative 'drying_rails/version'
require_relative 'drying_rails/view_helpers'
require_relative 'drying_rails/params_manager'
require_relative 'drying_rails/controller_helpers'
require_relative 'drying_rails/model_helpers'

module DryingRails
  class Error < StandardError; end

  # Initialize DryingRails railtie
  class Railtie < Rails::Railtie
    initializer 'drying_rails' do
      require_relative 'initializers/container_initializer'
      require_relative 'initializers/component_initializer'
      require_relative 'initializers/view_helpers_initializer'
      require_relative 'initializers/controller_helpers_initializer'
      require_relative 'initializers/model_helpers_initializer'
      require_relative 'initializers/exposer_initializer'
    end
  end
end
