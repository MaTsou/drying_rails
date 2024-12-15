class ::DryingComponent
  attr_reader :view, :config

  def defaults
    { class: nil, style: nil }
  end

  def configure( view, **options )
    @view = view
    @config = update_config( defaults, options )
    self
  end

  def render( **options, &block )
    @config = update_config( @config, options )
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

  def update_config( last, incoming )
    config = last.dup
    config[ :class ] = [ config[:class], incoming.delete( :class ) ].join ' '
    config[ :style ] = [ config[:style], incoming.delete( :style ) ].join ' '
    config.merge incoming
  end

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

