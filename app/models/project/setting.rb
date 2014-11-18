class Project::Setting < ActiveRecord::Base
  belongs_to :executable
  belongs_to :parameter_space
end
