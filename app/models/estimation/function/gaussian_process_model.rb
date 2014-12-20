class Estimation::Function::GaussianProcessModel < Estimation::Function

  def big_sigma_inverse
    @big_sig_inv ||= self.inv_var_matrix.map {|v| v * self.sig2}
  end

  def corr_response
    big_sigma_inverse * (self.result_vector.map {|v| v - self.mu}) if !!self.inv_var_matrix && !!self.result_vector
  end

end