class MathModel::Run < ActiveRecord::Base
  belongs_to :project_settings
  has_many :powder_data_quality_metrics, class_name: "Data::QualityMetric"
end
