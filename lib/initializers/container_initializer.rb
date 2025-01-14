require 'dry/system'

class MyResult
  def set( type, value = true, *args )
    content = args.empty? ? value : args.unshift( value )
    { type => content }
  end
end

class ::DryingContainer < Dry::System::Container
  configure do |config|
    config.root = Rails.root
    config.component_dirs.add 'app/drying'
  end
  self.register 'result', MyResult.new
  self.finalize! if Rails.env.production?
end
::Deps = DryingContainer.injector
