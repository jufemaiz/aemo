module HashConstructed
  attr_accessor :attributes

  def initialize(h)
    @attributes = h
  end

  def method_missing(method, *arguments, &block)
    if @attributes.include? method
      @attributes[method]
    else
      super
    end
  end
end
