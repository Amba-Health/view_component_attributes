require "rails_helper"

describe ViewComponentAttributes::WithUnknownAttributes do
  let(:subject_class) do
    Class.new do
      include ViewComponentAttributes::WithUnknownAttributes

      attribute :known_attribute
    end
  end

  it "Gathers unknown attributes" do
    subject = subject_class.new(known_attribute: 1, unknown: "What's that?")

    expect(subject.known_attribute).to eq(1)
    expect(subject.unknown_attributes).to eq({unknown: "What's that?"})
  end

  it "Returns an empty hash if there's no unknow attributes" do
    subject = subject_class.new(known_attribute: 1)
    expect(subject.known_attribute).to eq(1)
    expect(subject.unknown_attributes).to eq({})
  end
end
