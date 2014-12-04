class PowderData::EmulatedPoints < ActiveRecord::Base
  has_one :math_model_run, class_name: "MathModel::Run"
  serialize :points, JSON
  
  class << self
    def from_run(run)
      # extraction of points is subject to change once more adapters are introduced
      #TODO: change points extraction
      points = run.result["value"]
      new(points: points)
    end
  end
end
