class PowderData::QualityMetric::Chi2 < PowderData::QualityMetric
  belongs_to :math_model_run, class_name: "MathModel::Run"
  
  class << self
    
    def factory(params = {})
      measured = get_points(params[:measured])
      emulated = get_points(params[:emulated])
      run = params[:run]
      sum = 0
      measured.each_with_index do |expected, index|
        sum += perform_single(emulated[index], observed)
      end
      new(value: sum, math_model_run: run)
    end

    def evaluate(*vars)
      qm = new
      if vars[0].class.to_s == "MathModel::Run"
        qm.value = perform_comparison(vars[0].get_emulated_points, vars[0].get_measured_points)
        qm.math_model_run = vars[0]
      elsif vars[0].class.to_s == "PowderData::MeasuredPoints" && vars[1].class.to_s == "PowderData::EmulatedPoints"
        qm.value = perform_comparison(vars[1].points, vars[0].points)
      elsif vars[1].class.to_s == "PowderData::MeasuredPoints" && vars[0].class.to_s == "PowderData::EmulatedPoints"
        qm.value = perform_comparison(vars[0].points, vars[1].points)
      else
        qm.value = perform_comparison(vars[0], vars[1])
      end
      return qm
    end

    def perform_comparison(observed_array, expected_array)
      raise Exceptions::DimensionsMismatch, "length of observed and expected datapoints differ" if observed_array.length != expected_array.length
      sum = 0
      observed_array.map.with_index do |val, index|
        sum += perform_single(val, expected_array[index])
      end
      res = (sum / observed_array.length).to_f
      p res.class
      res
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
