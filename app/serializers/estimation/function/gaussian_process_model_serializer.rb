class Estimation::Function::GaussianProcessModelSerializer < ActiveModel::Serializer
  attributes :id, :input_matrix, :result_vector, :corr_response, :mu, :sig2, :theta, :measured_points, :parameter_space, :inv_var_matrix, :big_sigma_inverse

  def measured_points
    object.measured_points.points
  end

  def parameter_space
    object.parameter_space.content
  end

end
