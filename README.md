# DryingRails

This gem provides a way to organize code in a Rails app. Many things are 
written about thin controller and fat model.. Here, largely inspired by Hanami 
2 project, thin controller and thin model become reality.

## Installation

This gem is not on `rubygems.org`. To install it, add `gem 'drying_rails', 
github: "MaTsou/drying_rails"` to your Gemfile and run `bundle install`.

## Usage

This gem provides a few things helping you to follow the `single responsability
principle` beyond the Rails way (I think !). All these things are independant 
from each other (except the dry-system container) and you can use only those 
you agree with.

First of all, you need to add a `drying` subfolder to `app` folder. All drying 
things will live here.

A `dry-system` container is provided and automatically register the all 
`drying` folder. Then in any class (controller, actions, services.. any except 
model !) in your app, dependency injection is easy using the dry-system way 
(see 
[dry-system](https://dry-rb.org/gems/dry-system/1.0/dependency-auto-injection/)) 
: in `drying_rails` the dependency _injector_ is `Deps` :
```
class MyClass
  include Deps[ '...' ]
```

#### Drying views
You may want to dry your views. Use components and our provided `component` helper.

```
# component helper syntax
<%= component( 'name', **options_a ).render( **options_b ) %>
```
+ `name` is the path to component in `app/drying/components` folder. So 
`component( 'icon.trash' )` will refer to the `app/drying/components/icon/trash.rb` file
+ `options_a` first round of options configuration.
+ `options_b` second round.
These two rounds allow you to share configuration among multiple rendering 
of a dedicated component :
```
<% icon = component( 'icon.base', class: "home-page-icon" ) %>
<%= icon.render( name: 'home' ) %>
<%= icon.render( name: 'back' ) %>
<%= icon.render( name: 'settings' ) %>
```
When calling `component( 'name', **options_a)`, `options_a` is merged to a 
default configuration hash. When `render( **options_b)` is called, `options_b` 
is merged to the configuration (eventually overriding previous config).

All this configuration is holded by the `config` hash (readable attribute of 
`DryingComponent` subclasses).
```
# Creating a component as a DryingComponent subclass.
# app/drying/components/icon/base.rb
module Components
  module Icon
    class Base < DryingComponent
      def erb_template # a file template is also allowed; see DryingComponent code
        <<~ERB
          <%= content_tag icon_tag, '', icon: icon_name, **options %>
        ERB
      end

      def provided_vars
        { # from config hash to template needed values..
          icon_name: icon_name,
          icon_tag: "iconify-icon",
          options: {
            inline: true,
            style: config.fetch( :style, nil ),
            class: config.fetch( :class, nil ),
          }.compact
        }
      end

      private
      def icon_name # no more code in views !
        "mdi:#{config[:name]}"
      end
  end
end
```
+ A `render?` method (default to true) exists to manage conditional rendering.
+ A `defaults` method (default to empty hash) exists to provide default 
  configuration.

#### Drying controllers
Separation of concerns means, to me, that controllers do not have to deal with 
model things nor view things. There job is to control flow.
1. Receiving data, they call dedicated `actions` (which do the model thing),
1. Then, eventually, they call dedicated `services` (which do non-model related job)
1. Then, they call dedicated `exposers` to provide the needed content to the next view.


+ Actions are classes responding to a unique public method : `call`. They live 
  in `app/drying/actions` to be correctly registered in the container and for 
  the drying controller `perform` helper to work.
  ```
  # app/drying/actions/posts.rb
  module Actions
    module Posts
      class Base
        include Deps[ 'result' ] # a ThyResult instance..(see thy_result gem)
        # eventual common code for post actions here
      end
    end
  end

  # app/drying/actions/posts/create.rb
  module Actions
    module Posts
      class Create < Posts::Base
        def call( context )
          # context is a Ustruct (see ustruct gem : unmutable struct) containing the given parameters
          post = Post.create( context.params )
          status = post.valid? ? :Success : :Failure
          result.set( status, post )
        end
      end
    end
  end
  ```

+ Services are classes responding to a unique public  method : `call`. They 
  live in `app/drying/services`.
  ```
  # app/drying/services/email_notifier.rb
  module Services
    class EmailNotifier
      def call( context )
        # whatever
      end
    end
  end
  ```

+ Exposers are classes to put together all stuff needed to a view. They 
  subclass the `DryExposer` class. They live in `app/drying/exposers` folder. I 
  try to mimic `Hanami` syntax using an `expose` method. They, like `Hanami`, 
  also provide automatic module decoration with `Presenters` (Hanami Parts). 
  See docs for complete syntax.

  `context` is a Ustruct containing calling 
  options. If `context` provide an already name stuff (here `post`), the 
  exposer do not call corresponding expose method..
  ```
  # app/drying/exposers/posts.rb
  module Exposers
   module Posts
      class Base < DryExposer
        # common stuff
      end
    end
  end

  # app/drying/exposers/posts/new.rb
  module Exposers
    module Posts
      class New < Posts::Base
        include Deps[ query: 'actions.posts.new' ]

        expose :post do |context:|
          query.call context
        end # make a `post` local var available in view.
      end
    end
  end
  ```

+ Presenters are modules living in `app/drying/presenters` folder.
  ```
  # app/drying/presenters/input.rb
  module Presenters
    module Input
      # will automatically extend `input` exposure.
    end
  end
  ```

Controller flow :
  + `perform` is a drying controller helper to call actions. It resolves the 
    action name and wrap given options to a Ustruct context variable.
  + `execute` is a drying controller helper used to call any container content 
    (like services).
  + `locals_for` is a drying controller helper to call exposers. The controller 
    can provide its own locals and exposer eventually complete (but do not 
    override) the list. Below, `new` method render the post-new view with a 
    `post` local provided by exposer and `create` method render (on creation 
    failure) the post-new view with a `post` local provided by controller.

  Note : this way, controller needs to **explicitely** call a view.

  Note (bis) : `perform` is syntactic sugar, calling `execute` under the hood. 
  `perform( 'posts.create', ... )` is equivalent to `execute( 
  'actions.posts.create', ...)`. 

  Note (ter) : `locals_for` is syntactic sugar, calling `execute` under the hood. 
  `locals_for( 'posts.new', ... )` is equivalent to `execute( 
  'exposers.posts.create', ...)`.

  ```
  # app/controllers/posts_controller.rb
  def new
    render :new, locals_for( 'posts.new' ) # here post local is not provided
  end

  def create
    perform( 'posts.create', params: permitted_params ) do |result|
      result.isSuccess do
        execute( 'services.email_notifier', ... )
        redirect_to :home, status: :see_other
      end
      result.isFailure do |post|
        render :new,
          locals: locals_for( 'posts.new', post: post ), # here post local is provided
          status: :unprocessable_entity
      end
    end
  end
  ```

#### Hey, another drying thing : `permitted_params`
There is a functionnality where controllers need (a priori) to know 
about model. This is parameter permission. I provide a way to keep this 
responsability inside controller (this is its job) but model provide the field 
lists.

`permitted_params` as used above is a `drying_rails` controller helper. It 
resolves model name form current controller name and permits  params provided 
by `permitted_attributes` model class method : if model respond to 
`numerical_attributes` class method, a conversion from `,` decimal separator to 
`.` will occur.
```
class Post < ApplicationRecord
  class < self
    def permitted_attributes
      [ :content, :date, :a_numerical_field, ... ]
    end

    def numerical_attributes
      [ :a_numerical_field, ... ]
    end
  end
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
