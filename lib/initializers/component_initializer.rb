# frozen_string_literal: true

# drying component class
class ::DryingComponent
  attr_reader :view

  def defaults
    { class: nil, style: nil }
  end

  def configure(view, **options)
    @view = view
    @_config = update_config(defaults, options)
    self
  end

  def config
    defined?(@config) ? @config : @_config
  end

  def render(**options)
    @config = update_config(@_config, options)
    return unless render?

    view.render(**rendered_object, locals: provided_vars)
  end

  def partial_name
    nil
  end

  def render?
    true
  end

  def provided_vars
    {}
  end

  private

  def update_config(last, incoming)
    config = last.dup
    config[:class] = merge_class config[:class], incoming.delete(:class)
    config[:style] = merge_style config[:style], incoming.delete(:style)
    config.merge incoming
  end

  def merge_class(first, second)
    klasses = first ? pretty_split(first, ' ') : []
    klasses << pretty_split(second, ' ') if second
    klasses.join ' '
  end

  def merge_style(first, second)
    style_to_hash(first)
      .merge(style_to_hash(second))
      .to_a
      .map { |s| s.join(': ') }
      .join('; ')
  end

  def style_to_hash(style)
    return {} unless style

    pretty_split(style, ';').to_h { |s| pretty_split(s, ':') }
  end

  def pretty_split(str, sep)
    str
      .split(sep)
      .map(&:strip)
      .reject(&:empty?)
  end

  def rendered_object
    return { inline: erb_template } if inline_template?

    { partial: [partial_folder, partial_name].join }
  end

  def inline_template?
    respond_to?(:erb_template)
  end

  def partial_folder
    'components/'
  end
end
