# This class is an adapter layer between the physical model and the powder code
# Mostly it's meant to switch over from mathematica at some point to something else

class MathModel::Adapter

  # constant is used to return the path
  # should be exchanged at some point to paperclip or something
  ModelDirectory = "lib/math_models"
  
  # returns the constant for the model directory
  def self.directory
    return ModelDirectory
  end
  

  # this method must be implemented by all subclasses
  def executable_prefix(specifier = nil)
    raise Exceptions::NotImplementedError, self.class.to_s + " not implemented" if specifier.nil?
    [ModelDirectory, specifier].join("/")
  end
  

  # method makes the actual system call
  # @param command [String] string that you would use on a commandline to run the desired script (no leading ./, no params)
  # @param params [MathModel::InputParams, Array] the input params for the model call
  def systemcall(command, params)
    params = MathModel::InputParams.convert(params)
    system("./" + command + " " + params.to_s)
  end
  
  
end