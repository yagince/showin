class SimpleStruct
  def initialize(options)
    @struct = Struct.new(*options.keys).new(*options.values)
  end
  def method_missing(action, *args)
    @struct.send(action, *args)
  end
end
