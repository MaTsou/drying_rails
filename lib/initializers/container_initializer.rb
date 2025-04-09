# frozen_string_literal: true

require 'dry/system'

# my_result class
class MyResult
  def set(type, *args)
    content = args.empty? || process(*args)
    { type => content }
  end

  def process(*args)
    # take care, args.one? returns false on [false] !
    args.size == 1 ? args.pop : args
  end
end

# drying container class
class ::DryingContainer < Dry::System::Container
  configure do |config|
    config.root = Rails.root
    config.component_dirs.add 'app/drying'
  end
  register 'result', MyResult.new
  finalize! if Rails.env.production?
end
Deps = DryingContainer.injector
