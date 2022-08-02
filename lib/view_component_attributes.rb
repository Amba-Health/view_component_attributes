require "view_component_attributes/version"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module ViewComponentAttributes
  class Error < StandardError; end
  # Your code goes here...
end
