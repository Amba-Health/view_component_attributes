##
# Allows gathering of unknown attributes
# when setting attributes on a Component
# (or any ActiveModel, for that matter).
#
# This lets us collect the extra attributes
# to be used as HTML attributes later on
module WithUnknownAttributes
  extend ActiveSupport::Concern
  include WithAttributes

  def assign_unknown_attribute(attribute_name, value)
    unknown_attributes[attribute_name.to_sym] = value
  end

  def unknown_attributes
    @unknown_attributes ||= {}
  end

  private

  ##
  # Overrides the _assign_attribute method
  # to avoid adding many computations during
  # component instanciation.
  def _assign_attribute(k, v)
    setter = :"#{k}="
    if respond_to?(setter)
      public_send(setter, v)
    else
      assign_unknown_attribute(k, v)
    end
  end
end
