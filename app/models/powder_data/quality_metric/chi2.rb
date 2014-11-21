class PowderData::QualityMetric::Chi2 < PowderData::QualityMetric
  belongs_to :math_model_run, class_name: "MathModel::Run"
  
  class << self
    
    def factory(params{})
      measured = get_points(params[:measured])
      emulated = get_points(params[:emulated])
      run = params[:run]
      sum = 0
      measured.each_with_index do |expected, index|
        sum += perform_single(emulated[index], observed)
      end
      new(value: sum, math_model_run: run)
    end
    
    def perform_single(observed, expected)
      v = observed.to_f - expected.to_f
      v2 = v * v
      res = v2 / expected
      return res
    end
    
    private
    
    def get_points(obj)
      return obj.points if obj.respond_to?(:points)
      obj
    end
  end
  
end
