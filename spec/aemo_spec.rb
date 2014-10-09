require "spec_helper"

describe AEMO do
  before(:each) do
    @klass = Class.new
    @klass.instance_eval { include AEMO }
  end
end
