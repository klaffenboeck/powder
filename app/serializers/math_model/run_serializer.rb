class MathModel::RunSerializer < ActiveModel::Serializer
  attributes :id, :quality_metrics, :input_params, :emulated_points
  
end
