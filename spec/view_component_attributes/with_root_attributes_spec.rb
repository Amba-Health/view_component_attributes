require "rails_helper"

describe ViewComponentAttributes::WithRootAttributes do
  describe "Class methods" do
    it "Allows to configure static attributes as positional param" do
      component_class = Class.new do
        include ViewComponentAttributes::WithRootAttributes

        root_attributes(class: "a-class")
      end

      component = component_class.new

      expect(component.root_attributes).to eq(class: "a-class")
    end

    it "Allows to compute attributes from instance" do
      component_class = Class.new do
        include ViewComponentAttributes::WithRootAttributes

        attribute :type

        root_attributes do
          {
            data: {
              type: type
            }
          }
        end
      end

      component = component_class.new(type: "info")

      expect(component.root_attributes).to eq(data: {type: "info"})
    end
  end

  describe "#root_attributes" do
    it "Merges the default, template and unknown attributes" do
      component_class = Class.new do
        include ViewComponentAttributes::WithRootAttributes

        attribute :type

        root_attributes({class: "static-class"}) do
          {
            data: {
              type: type
            }
          }
        end
      end

      component = component_class.new(
        root_attributes: {
          data: {
            controller: "alert"
          }
        },
        type: "info",
        id: "the-id",
        class: {"another-class": true}
      )

      expect(component.root_attributes(class: "some-class")).to eq({
        id: "the-id",
        class: "static-class some-class another-class",
        data: {
          type: "info",
          controller: "alert"
        }
      })
    end
  end
end
