class Project::Setting < ActiveRecord::Base
  belongs_to :executable
  belongs_to :parameter_space
  belongs_to :measured_points, class_name: "PowderData::MeasuredPoints"
  
  
  def get_adapter
    adapter.constantize
  end
  
  private
  
  
end
