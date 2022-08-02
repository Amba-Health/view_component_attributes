module ViewComponentAttributes
  module WithAttributes
    extend ActiveSupport::Concern
    include ActiveModel::Model
    include ActiveModel::Attributes

    # Little gotcha as the internal @attributes AttributeSet
    # used by ActiveModel::Model uses String keys.
    # https://github.com/rails/rails/blob/76489d81ba77216271870e11fba6889088016fa5/activemodel/lib/active_model/attributes.rb#L99
    # It's very natural to use a Symbol here,
    # so turning the name into a string
    # to avoid pitfals
    def attribute(name)
      super(name.to_s)
    end
  end
end
