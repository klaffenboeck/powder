class MathModel::RunSerializer < ActiveModel::Serializer
  attributes :id, :quality_metrics, :emulated_points
end
