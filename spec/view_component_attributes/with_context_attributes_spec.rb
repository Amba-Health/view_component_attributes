require "rails_helper"

describe ViewComponentAttributes::WithContextAttributes do
  it "Merges the attributes inside the block" do
    # TODO: Find out what makes it work for ViewComponent::Base
    # but not a regular class
    component_class = Class.new(ViewComponent::Base) do
      include ViewComponentAttributes::WithUnknownAttributes
      include ViewComponentAttributes::WithContextAttributes
    end

    instance = component_class.with_attributes(id: 'default-id', class: 'other-class') do
      component_class.new(id: 'instanciated-id', class: 'a-class', data: {controller: 'some-controller'})
    end

    expect(instance.unknown_attributes).to eq({
      id: 'instanciated-id',
      class: 'other-class a-class',
      data: {controller: 'some-controller'}
    })
  end

end
