##
# Most components are wrapped in a single root element/component
# This module formalises this with:
# - The configuration of that root element, either:
#    - at class level using the `root` class method
#    - at instanciation through the `root` (or `tag_name`) attribute
# - The rendering of the root using the `root` instance method.
#
#    **Passing attributes**
#
#    It accepts a hash of attributes and a block with the content
#    to be rendered inside the root. The attributes can be processed
#    using the `root_attributes` instance method
#    (for ex. with the `WithRootAttributes` concern)
#
#    ```haml
#      = root(class: 'a-class', id: 'the-id') do
#        = "Content of the component goes here"
#    ```
#
#    **Customizing root element/component**
#
#    To keep semantics in the same place, you can also provide
#    the root element/component at render time as a positional arg
#
#    ```haml
#    = root(:ul, class: 'list-group') do
#      - collection.each do
#        %li.list-group-item
#    ```
#
#    That value is processed by the `root_type` method that you can
#    override should the root element/component depend on some
#    logic from the component:
#
#    ```rb
#    def root_type(template_root)
#      if ordered?
#        :ol
#      else
#        :ul
#      end
#    end
#    ```

module WithRoot
  extend ActiveSupport::Concern

  include WithAttributes

  included do
    # Class attribute to store default set at class definition
    class_attribute :default_root, default: :div

    # Instance attributes to store value configured at instanciation
    attribute :root
    alias_attribute :tag_name, :root
  end

  class_methods do
    def root(tag_name_or_component)
      self.default_root = tag_name_or_component
    end
  end

  def root(template_root = nil, **template_attributes, &block)
    root_to_render = root_type(template_root)

    if root_to_render.is_a?(Class)
      render(root_to_render.new(**root_attributes(**template_attributes)), &block)
    else
      tag.send(root_to_render, **root_attributes(**template_attributes), &block)
    end
  end

  def root_type(template_root)
    @root_type ||= attribute(:root) || template_root || default_root
  end

  def root_attributes(**template_attributes)
    template_attributes
  end
end
