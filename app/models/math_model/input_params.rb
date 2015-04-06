class MathModel::InputParams
  include ActiveModel::Model
  attr_accessor :params
  
  class << self
    def get_test_params
      new(params: [0,0, 11, 10.045])
    end

    def convert(*args)
      if args.length == 1
        arg = args.first
        return arg if arg.is_a?(self)
        return self.new(params: arg) if arg.is_a?(Array)
      end
      return self.new(params: args)
    end
  end
  
  def to_s
    mapped = params.map {|num| "%.15f" % num}
    mapped.join(" ")
  end
  
  alias_method :to_string, :to_s
  alias_method :to_str, :to_s
end