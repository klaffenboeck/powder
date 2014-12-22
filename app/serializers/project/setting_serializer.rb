class Project::SettingSerializer < ActiveModel::Serializer
  attributes :id, 
    :parameter_space, 
    :name, 
    :description, 
    :accuracy, 
    :measured_points, 
    :data_angles, 
    :run_list, 
    :runs,
    :estimation_function

  def runs
    object.run_list.runs
  end

  def estimation_function
    object.estimation_function.serialize
    
  end
end
