module ViewComponentAttributes
  module WithRootAttributes
    ##
    # Formalises the generation of the attributes of the root
    # element/components. It defines the `root_attributes`
    # method to merge attributes configured at different
    # points of the component's lifecycle:
    # - class definition, through a `root_attributes` class method
    #   allowing to set either (but not both, for now):
    #   - a static hash of attributes
    #     ```rb
    #     root_attributes {class: 'component-class'}
    #     ```
    #   - a block that'll get evaluated against the component when
    #     the attributes are generated.
    #     ```rb
    #     root_attributes do
    #       {
    #         class: compute_the_class
    #       }
    #     end

    #     def compute_the_class
    #       ...
    #     end
    #     ```
    #   - overriding the `dynamic_root_attributes` method for computations
    #     that don't fit in a block. It can return an Array of attribute hashes.
    #     Don't forget to call `super`
    # - attribute computation, collecting the keyword arguments
    #   to the `root_attributes` call so that relevant groups
    #   of related attributes (BEM classes, Stimulus controller and targets)
    #   can live in the same file (template or class)
    # - object instanciation, through:
    #   - the collection of the `unknown_attributes`
    #   - a `root_attributes` attribute passed to `new`

    #   ```
    #     HasRootAttributesComponent.new(
    #       root_attributes: {
    #         class: 'a-class'
    #       },
    #       id: 'the-id'
    #     ) # Will have `{class: 'a-class', id: 'the-id'}` as root attributes
    #   ```
    #
    # **Controlling merge order**
    #
    # By default, attributes are merged from the "most generic" (class definition) place of declaration
    # to the "most specific" (object instanciation, to allow manual setting of any attributes)
    #
    # 1. static_root_attributes # Instance method
    # 2. dynamic_root_attributes # Instance method
    # 3. template_attributes # Arguments of `root_attributes`
    # 4. unknown_attributes # Instance method
    # 5. instance_root_attributes # Instance method
    #
    # If a different order is required for a specific component,
    # you can override the `root_attributes` method to `merge_attributes`
    # in the relevant order.
    extend ActiveSupport::Concern

    include ViewComponentAttributes::WithAttributes
    include ViewComponentAttributes::WithUnknownAttributes
    # Necessary to include MergeAttributes::Helper
    include ActionView::Helpers::TagHelper
    include MergeAttributes::Helper

    included do
      attribute :root_attributes

      class_attribute :static_root_attributes, instance_accessor: false
    end

    class_methods do
      def root_attributes(default_value = nil, &block)
        if block
          # Allows to have the right scope when running the block
          define_method :get_default_root_attributes, &block
        end

        self.static_root_attributes = default_value
      end
    end

    def root_attributes(**template_attributes)
      merge_attributes(
        static_root_attributes,
        dynamic_root_attributes,
        template_attributes,
        unknown_attributes,
        instance_root_attributes
      )
    end

    def instance_root_attributes
      attribute(:root_attributes)
    end

    def dynamic_root_attributes
      if respond_to?(:get_default_root_attributes)
        get_default_root_attributes
      end
    end

    def static_root_attributes
      singleton_class.static_root_attributes
    end
  end
end
