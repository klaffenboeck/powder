class Estimation::RawData < ActiveRecord::Base
  serialize :normal_sample_point_matrix, JSON
  serialize :theta, JSON
  serialize :inv_var_matrix, JSON
  
  class << self
    def factory(params = {})
      raw_data = new
      cols = params[:cols] || 5
      rows = params[:rows] || 50
      raw_data.generate_sample_points(rows, cols)
      return raw_data
    end
  end
  
  def generate_sample_points(rows, cols)
    R.eval "mat = maximinLHS(#{rows}, #{cols})"
    self.normal_sample_point_matrix = R.pull "mat"
  end
  
  def map_parameter_space(boundaries, matrix)
    matrix.to_a.map do |matrix_row|
      matrix_row.to_a.each_with_index.map {|col, i| map_normal_to_sample_point(col, boundaries[i])}
    end
  end
  
  def map_normal_to_sample_point(normal, range_array)
    range = range_array[1] - range_array[0]
    range_array[0] + range * normal
  end
  
  def nspm
    self.normal_sample_point_matrix
  end
  
  alias_method :get_nspm, :nspm
  
  def get_first
    self.nspm.to_a.first
  end
end
