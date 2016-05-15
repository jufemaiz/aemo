require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe AEMO do
  before(:each) do
    @klass = Class.new
    @klass.instance_eval { include AEMO }
  end
end
