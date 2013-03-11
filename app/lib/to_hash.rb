module ToHash
  def to_hash
    instance_variables.inject({}) { |h, name|
      value = instance_variable_get(name)
      h[:"#{name[1..-1]}"] = value.respond_to?(:to_hash) ? value.to_hash : value
      h
    }
  end
end
