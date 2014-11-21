class MathModel::InputParams
  include ActiveModel::Model
  attr_accessor :params
  
  class << self
    def get_test_params
      new(params: [0,0, 11, 10.045])
    end
  end
  
  def to_s
    params.join(" ")
  end
  
  alias_method :to_string, :to_s
end