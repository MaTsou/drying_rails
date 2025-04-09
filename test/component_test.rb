# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/initializers/component_initializer'

class MyComponent < ::DryingComponent
  def defaults
    { class: 'default_class', style: 'default_style: 3;' }
  end

  def provided_vars
    {
      var1: 'var1_content',
      var2: 'var2_content',
      var3: config[:class],
      var4: config[:style]
    }
  end

  def erb_template
    <<~ERB
      <div><%= var1 %><div>
      <p><%= var2 %><p>
    ERB
  end
end

describe DryingComponent do
  before do
    @my_component = MyComponent.new
    @my_view = Minitest::Mock.new
  end

  it 'calls view.render method with inline_template' do
    @my_view.expect :render, 'hello' do |**given|
      given.fetch(:inline, false) && given[:locals] == {
        var1: 'var1_content',
        var2: 'var2_content',
        var3: 'default_class',
        var4: 'default_style: 3'
      }
    end
    _(@my_component.configure(@my_view).render).must_equal 'hello'
    @my_view.verify
  end

  it 'correctly update config on configure call' do
    @my_view.expect :render, 'hello' do |**given|
      given.fetch(:inline, false) && given[:locals] == {
        var1: 'var1_content',
        var2: 'var2_content',
        var3: 'default_class new_class',
        var4: 'default_style: 3; color: red'
      }
    end
    _(
      @my_component.configure(
        @my_view,
        class: '  new_class ',
        style: ' color:  red ;'
      ).render
    )
      .must_equal 'hello'
    @my_view.verify
  end

  it 'correctly update config on render call' do
    @my_view.expect :render, 'hello' do |**given|
      given.fetch(:inline, false) && given[:locals] == {
        var1: 'var1_content',
        var2: 'var2_content',
        var3: 'default_class new_class',
        var4: 'default_style: 3; color: red'
      }
    end
    _(
      @my_component.configure(@my_view).render(
        class: 'new_class',
        style: ' color:  red ;'
      )
    )
      .must_equal 'hello'
    @my_view.verify
  end

  it 'correctly overide style config' do
    @my_view.expect :render, 'hello' do |**given|
      given.fetch(:inline, false) && given[:locals] == {
        var1: 'var1_content',
        var2: 'var2_content',
        var3: 'default_class new_class',
        var4: 'default_style: 6; color: red'
      }
    end
    _(
      @my_component.configure(@my_view).render(
        class: 'new_class',
        style: ' color:  red ; default_style: 6'
      )
    )
      .must_equal 'hello'
    @my_view.verify
  end
end
