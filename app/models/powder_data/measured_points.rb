class PowderData::MeasuredPoints < ActiveRecord::Base
  serialize :points, JSON
  has_many :project_settings, class_name: "Project::Setting"
  
end
