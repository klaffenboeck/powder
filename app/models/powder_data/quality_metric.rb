class PowderData::QualityMetric < ActiveRecord::Base
  belongs_to :math_model_run
  delegate :measured_points, to: :math_model_run
  scope :get, ->(name) {where("type = ?", "PowderData::QualityMetric::" + name.capitalize).first}
  
  def scalar(type = "real")
    value.to_f if ["real","r","float","f"].include?(type)
  end
end
