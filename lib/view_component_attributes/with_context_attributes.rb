module WithContextAttributes
  # Allows to configure default attributes for the component
  # specifically for the execution of a block. This comes handy
  # for passing defaults to sub-components without having
  # to have each component in the chain passing them down
  #
  # ```
  # - Component.with_attributes(option: 'value') do
  #   -# Say `GrandParendComponent` renders a `ParentComponent`
  #   -# Which in turn renders our `Component`
  #   -# Our component will have its `option` attribute defaulted
  #   -# to `'value'` when called without having `GrandParentComponent`
  #   -# or `ParentComponent` having to take responsibility for passing it
  #   = render GrandParentComponent.new(...)
  # ```

  extend ActiveSupport::Concern
  include WithAttributes
  include MergeAttributes::Helper

  included do
    class_attribute :block_attributes

    # Prepend the initializer so its `super` calls
    # the class' `initialize` method rather than
    # the other way around
    prepend WithContextAttributes::Initializer
  end

  class_methods do
    def with_attributes(**attributes)
      self.block_attributes = attributes

      yield
    ensure
      self.block_attributes = nil
    end
  end

  module Initializer
    def initialize(*args, **initialize_attributes)
      super(*args, **merge_attributes(block_attributes || {}, initialize_attributes))
    end
  end
end
