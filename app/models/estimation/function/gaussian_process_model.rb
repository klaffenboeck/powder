class Estimation::Function::GaussianProcessModel < Estimation::Function

  def corr_response
    self.inv_var_matrix * self.result_vector
  end
end