class MathModel::RunList
  include ActiveModel::Model
  attr_accessor :runs
  
  class << self
    def factory(content)
      return from_input_params_list(content) if content.is_a?(MathModel::InputParamsList)
    end
    
    private 
    
    def from_input_params_list(input_params_list)
      
    end
  end
  
  public
  
  def initialize(attributes = {})
    super
    self.runs = []
  end
  
  def add(run)
    raise Exceptions::TypeMismatch if !run.is_a?(MathModel::Run)
    self.runs << run
  end
  

  
  
end