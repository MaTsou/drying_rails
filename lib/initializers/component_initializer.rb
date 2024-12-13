class ::DryingComponent
  attr_reader :view, :config

  def defaults
    {}
  end

  def configure( view, **options )
    @view = view
    @config = defaults.merge( options )
    self
  end

  def render( **options, &block )
    @config = @config.merge( options )
    return unless render?
    view.render **rendered_object, locals: provided_vars
  end

  def partial_name; nil; end

  def render?
    true
  end

  def provided_vars
    {}
  end

  private

  def rendered_object
    inline_template? ?
      { inline: erb_template } :
      { partial: [ partial_folder, partial_name ].join }
  end

  def inline_template?
    respond_to?( :erb_template )
  end

  def partial_folder
    "components/"
  end
end

