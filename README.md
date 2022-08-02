# ViewComponentAttributes

This Gem helps the management of attributes received by View Components (or props, options, however you name them). It offers a set of concerns to mix into your components to:

- declare the attributes your component expects to receive. Backed by ActiveModel's API for familiarity
- collect attributes not declared by the component, for later use as HTML attributes in rendering to set ad-hoc classes or Stimulus controllers, for example
- declaring a component's "root" element and managing its attributes either in the class or the template
- merging attributes coming from outside the component with those computed inside its class and template
- defining temporary defaults for component's attributes, allowing to customise the rendering of sub-components without passing attributes at each step

You can buy in as much or as little of this as you want by picking the concerns you include, it's up to you.

## Usage

Pick and chose the concern to include in your components to give them more or less power

###  `WithAttributes`: Declare expected attributes

Include the `WithAttributes` concern to let your component declare the attributes it expects with the same `attribute` API as ActiveModel (a similar take as [`view_component-contrib`'s use of `dry-initializer`](https://github.com/palkan/view_component-contrib#hanging-initialize-out-to-dry)).

```rb
class MyComponent < ViewComponent::Base
    include ViewComponentAttributes::WithAttributes

    attribute :some_attribute
    attribute :attribute_with_default, default: 5

    # If you need to compute a default based on other attributes
    # you can override the getter and use ActiveModel's `attribute`
    # method to read any value provided to the component
    attribute :attribute_with_computed_default
    def attribute_with_computed_default
        attribute(:attribute_with_computed_default) || do_some_computation
    end
end
```

### `WithUnknownAttributes`: Collect unknown attributes for later use

By default `ActiveModel` will throw if you use unknown attributes during initialization. This makes models safer, but when it comes to the view, you often need to add attributes that shouldn't be the responsibility of the component itself:

- new `class`es because of where the component is rendered, or an `id` to be referenced by `aria-labelledby` or `aria-controls` for accessibility...
- Stimulus attributes to make the component a [target](https://stimulus.hotwired.dev/reference/targets), trigger an [action](https://stimulus.hotwired.dev/reference/actions) or maybe just some extra [controllers](https://stimulus.hotwired.dev/reference/controllers).

Include the `WithUnknownAttributes` concern to avoid an error being thrown and the extra attributes made available through the `unknown_attributes` method.

_Includes `WithAttribute`_

```rb
class MyComponent < ViewComponent::Base
    include ViewComponentAttributes::WithUnknownAttributes
end

component = MyComponent.new(class:'some-class', id: 'some-id')
component.unknown_attributes # {:class=>"some-class", :id=>"some-id"}
```

### `WithRoot` and `WithRootAttributes`: Declare a component's root element and manage its attributes

Most components have their content wrapped by a single root element or sub-component. `WithRoot` and `WithRootAttributes` help you define which element or component to use, and combine attributes from different places in a standardised way: declarative defaults (that can be computed), component's template and component's initialization.

They can each be used independently, but work best together:

```rb
class MyComponent < ViewComponent::Base
    # Needs to be first to ensure its `root_attributes` method
    # gets overriden as necessary by that of `WithRootAttributes`
    include ViewComponentAttributes::WithRoot
    include WithComponentAttributes::WithRootAttributes
end
```

#### Configuring the component's root element/component

`WithRoot` provides some help for declaring and rendering the component's root element or component.

From the template or the component's `call` method, the **`root` instance method** renders the root of the component.

    ```erb
    <%# my_component.html.erb %>
    <%= root(:article, class: "a-class", id: "an-id") do %>
        <%# Inside of the component gets rendered here %>
    <% end %>
    ```

The element or component's class to render can be passed as first positional parameters: a class will be treated as a component, anything else sent to the [`tag` helper](https://api.rubyonrails.org/v7.0.2/classes/ActionView/Helpers/TagHelper.html#method-i-tag).

If you don't provide any, whichever you provided using the `root` class method. This can help keep code related to each other in the same place rather than split across class and template. Default is a `<div>`, but please do take some time to use [elements with built-in semantics](https://developer.mozilla.org/en-US/docs/Web/HTML/Element) to give your users the best experience).

    ```rb
    class MyComponent < ViewComponent::Base
        root AnotherComponent
    end
    ```

That element or component will be rendered with the provided attributes and the block containing what's inside it.

Why not plainly set the element in the template (or `call`)? Using the `root` method sets you up for a consitent way to make computations for the rendering ot component's root:

- **picking the element or component of the root** with the `root_type` method when none is provided in the template. For example, this list component can switch its semantics based on an `ordered` attribute:

    ```rb
    class ListComponent < ViewComponent::Base
        include ViewComponentAttributes::WithAttributes
        include ViewComponentAttributes::WithRoot

        attribute :ordered

        def root_type(template_root)
            if (ordered)
                :ol
            else
                :ul
            end
        end

        def call
            root {content}
        end
    end
    ```

- **computing the attributes of that root element/component**, with the `root_attributes` method, potentially merging them from different origins.
That's what the `WithRootAttributes` concern takes advantage of to work its wonders.

####  Configuring the component's root attributes

`WithRoot` provides some structure, but is really mostly a setup for `WithRootAttribute`. This concern is responsible for mixing attributes coming from different part of the components:

- default attributes configured at class level, using the **`root_attributes` class method** (either as a hash, or a block if they require computations)
- attributes passed to the `root` method (or the **`root_attributes` instance method** if you need to compute root attributes for a helper like `link_to` or `form_for`)
- attributes passed to the component at initialization, those explicitely passed as the `root_attributes` attributes, as well as all the `unknown_attributes` gathered by the `WithUnknownAttributes` concern

```rb
class PostComponent
    include WithRoot
    include WithRootAttributes

    attribute :heading

    # At class-level, the root attributes can take
    # various shape:
    # A static set of attributes...
    root_attributes({class: 'a-class'})
    #
    # ...or a block, when computations are needed.
    #
    # That block can return a hash...
    root_attributes do
        {
            class: compute_the_class
        }
    end
    # 
    # ... or an array of hashes, allowing to separate different sets of attributes
    #
    root_attributes do
        [
            {
                class: compute_the_class
            },
            attributes_for_responsibility_a
            attributes_for_responsibility_b
        ]
    end

    def attributes_for_responsibility_a
        # ...
    end
    def attributes_for_responsibility_b
        # ...
    end
end
```

```erb
<%# 
    These extra attributes will be merged with the defaults,
    allowing them to stay grouped in the same file for easier understanding
%>
<%= root(:article, class: 'blog-article') do %>
    <h1 class="blog-article__heading"><%= heading %></h1>
    <div class="blog-article__body">
        <%= content %>
    </div>
<% end %>
```

```erb
<%# 
    Finally, attributes from instanciation will get merged in as well,
    allowing to set extra attributes based on: 
    - where the component is rendered,
    - what data it's rendering 
    - or anything else it's not responsible for.
    In case of collision of a root_attribute with one of the component,
    you can use the `root_attributes` attribute to make sure of which is which.
%>
<%= render PostComponent.new(
    heading: post.title, 
    id: dom_id(post),
    class: 'post-list__post'
) do %>
    <%= post.content %>
<% end %>
```

### `WithContextAttributes`: Setting temporary default attributes

Sometimes you have a `GrandParentComponent`, that renders a `ParentComponent`, that then renders a `ChildComponent`, which finally renders a `GrandChildComponent`. It's all nice... until in a specific scenario that `GrandChildComponent` needs an extra attribute, for that one time only.

Sure the `GrandParentComponent` could take it, pass it down, and so could the `ParentComponent` and the `ChildComponent`... until it reaches the `GrandChildComponent`. That's one more responsibility for them, which is not ideal. And after all, it's all the `GrandChildComponent` fault if that needs to happen so best it be the one handling it.

That's what the `WithContextAttributes` mixin handles. It adds a `with_attributes` class method to the `GrandChildComponent` to temporarily set defaults:

```erb
<% GrandChildComponent.with_attributes('data-accordion-target': 'content') do %>
    <%# 
        # Inside this block, new instances of `GrandChildComponent` will receive
        # the `data-accordion-target` attribute. 
    %>
    <%= render GrandParentComponent.new(...) %>
<% end %>
<%# 
    Back out of the block, new instances won't have the attribute, 
    it's back to normal
%>
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'view_component_attributes'
```

And then execute:

    bundle

Or install it yourself as:

    gem install view_component_attributes

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/[USERNAME>]/view_component_attributes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ViewComponentAttributes project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/view_component_attributes/blob/master/CODE_OF_CONDUCT.md).
