class Project::ManagerSerializer < ActiveModel::Serializer
  attributes :description, :accuracy #, :measured_points
end
