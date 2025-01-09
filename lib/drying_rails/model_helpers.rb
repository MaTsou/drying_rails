module DryingRails
  module ModelHelpers

    def include_deps( *args, **options )
      options.merge!(
        args.map do |str|
          [ str.split('.').last.to_sym, str ]
        end.to_h
      )

      options.each do |name, str_path|
        define_singleton_method( name ) { DryingContainer.resolve str_path }
        define_method( name ) { DryingContainer.resolve str_path }
      end
    end

  end
end
