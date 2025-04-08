# frozen_string_literal: true

module DryingRails
  # model helpers module
  module ModelHelpers
    def include_deps(*args, **options)
      options.merge!(
        args.to_h { |s| [s.split('.').last.to_sym, s] }
      )

      options.each do |name, str_path|
        define_singleton_method(name) { DryingContainer.resolve str_path }
        define_method(name) { DryingContainer.resolve str_path }
      end
    end
  end
end
