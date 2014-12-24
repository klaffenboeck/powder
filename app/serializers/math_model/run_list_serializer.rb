class MathModel::RunListSerializer < ActiveModel::Serializer
  attributes :id, :measured_points
  has_many :runs
end
