class MathModel::Adapter
  ModelDirectory = "lib/math_models"
  
  def self.directory
    return ModelDirectory
  end
  
  def executable_prefix(specifier = nil)
    raise Exceptions::NotImplementedError, self.class.to_s + " not implemented" if specifier.nil?
    [ModelDirectory, specifier].join("/")
  end
  
  def systemcall(command, params)
    system("./" + command + " " + params.to_s)
  end
  
  
end