class MathModel::Run < ActiveRecord::Base
  belongs_to :project_setting, class_name: "Project::Setting"
  has_many :powder_data_quality_metrics, class_name: "PowderData::QualityMetric"
  serialize :input_params, JSON
  serialize :result, JSON
  delegate :measured_points, to: :project_setting
  
  def input_params_obj
    return MathModel::InputParams.new(params: input_params["params"])
  end
  
  def result_obj
    return MathModel::Result.new(value: reslut["value"])
  end
end
