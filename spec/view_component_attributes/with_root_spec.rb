require "rails_helper"

describe ViewComponentAttributes::WithRoot, type: :component do
  describe "#root" do
    it "Renders a root tag with the relevant attributes" do
      component_class = Class.new(ViewComponent::Base) do
        include ViewComponentAttributes::WithRoot
      end

      component = component_class.new

      expect(component.root(:div, class: "root-class")).to have_css("div.root-class")
    end

    it "Renders a root component with the relevant attributes" do
      component_class = Class.new(ViewComponent::Base) do
        include ViewComponentAttributes::WithRoot
      end

      component = component_class.new

      expect(ViewComponent::Base).to receive(:new)
        .with(hash_including({class: "root-class"}))
        .and_call_original

      expect(component).to receive(:render)
        .with(instance_of(ViewComponent::Base))
        .and_return("Component rendered")

      expect(component.root(ViewComponent::Base, class: "root-class")).to eq("Component rendered")
    end

    it "Uses a `div` as default tag" do
      component_class = Class.new(ViewComponent::Base) do
        include ViewComponentAttributes::WithRoot
      end

      component = component_class.new

      expect(component.root(class: "root-class")).to have_css("div.root-class")
    end
  end

  describe "Support instance methods" do
    describe "#root_attributes" do
      it "Is used for picking the attributes" do
        component_class = Class.new(ViewComponent::Base) do
          include ViewComponentAttributes::WithRoot

          def root_attributes(template_attributes)
            {class: "root-class",
             **template_attributes}
          end
        end

        component = component_class.new

        expect(component.root(id: "root-id")).to have_css("div.root-class#root-id")
      end
    end

    describe "#root_type" do
      it "Is used for picking the type of root" do
        component_class = Class.new(ViewComponent::Base) do
          include ViewComponentAttributes::WithRoot

          def root_type(template_root)
            :article
          end
        end

        component = component_class.new

        expect(component.root(class: "root-class")).to have_css("article.root-class")
      end
    end
  end

  describe "Class methods" do
    describe "#root" do
      it "Configures the root as a tag" do
        component_class = Class.new(ViewComponent::Base) do
          include ViewComponentAttributes::WithRoot

          root :article
        end

        component = component_class.new

        expect(component.root(class: "root-class")).to have_css("article.root-class")
      end

      it "Configures the root as a component" do
        component_class = Class.new(ViewComponent::Base) do
          include ViewComponentAttributes::WithRoot

          root ViewComponent::Base
        end

        component = component_class.new

        expect(ViewComponent::Base).to receive(:new)
          .with(hash_including({class: "root-class"}))
          .and_call_original

        expect(component).to receive(:render)
          .with(instance_of(ViewComponent::Base))
          .and_return("Component rendered")

        expect(component.root(class: "root-class")).to eq("Component rendered")
      end
    end
  end
end
