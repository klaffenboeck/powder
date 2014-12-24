class Project::SettingSerializer < ActiveModel::Serializer
  attributes :id, 
    :parameter_space, 
    :name, 
    :description, 
    :accuracy, 
    :measured_points, 
    :data_angles, 
    :run_list, 
    :estimation_function

  # has_many :runs, through: :run_list

  def estimation_function
    object.estimation_function.serialize
  end
end
