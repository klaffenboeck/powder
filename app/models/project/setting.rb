class Project::Setting < ActiveRecord::Base
  belongs_to :executable
  belongs_to :parameter_space
  belongs_to :measured_points, class_name: "PowderData::MeasuredPoints"
  belongs_to :data_angles, class_name: "PowderData::DataAngles"
  has_one :run_list, as: :run_list_holder, class_name: "MathModel::RunList"
  has_one :estimation_function, class_name: "Estimation::Function", foreign_key: "project_setting_id"
  
  def get_adapter
    adapter.constantize
  end

end
