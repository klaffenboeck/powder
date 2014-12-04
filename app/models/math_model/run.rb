class MathModel::Run < ActiveRecord::Base
  belongs_to :project_setting, class_name: "Project::Setting"
  belongs_to :run_list, class_name: "MathModel::RunList"
  has_many :quality_metrics, class_name: "PowderData::QualityMetric", foreign_key: "math_model_run_id"
  belongs_to :emulated_points, class_name: "PowderData::EmulatedPoints"
  has_one :comparison, class_name: "PowderData::Comparison"
  serialize :input_params, JSON
  serialize :result, JSON
  delegate :measured_points, :adapter, to: :run_list
  
  def input_params_obj
    return MathModel::InputParams.new(params: input_params["params"])
  end
  
  def result_obj
    return MathModel::Result.new(value: result["value"])
  end
   
  def get_measured_points
    measured_points.points
  end

  def get_emulated_points
    emulated_points.points
  end

  # TODO: extend it so more qm are possible
  def calculate_quality_metric
    quality_metrics << PowderData::QualityMetric::Chi2.evaluate(self) if quality_metrics.length < 1
  end
end
