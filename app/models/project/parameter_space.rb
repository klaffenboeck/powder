class Project::ParameterSpace < ActiveRecord::Base
  has_many :project_settings, class_name: "Project::Setting"
  attr_accessor :json

  serialize :content, JSON
  
  def map_normals(raw_data)
    if check_dims(size, raw_data.get_first.length)
      params = raw_data.get_nspm.to_a.map do |matrix_row|
        matrix_row.to_a.each_with_index.map {|col,i| map_normal_to_sample_point(col, boundaries[i])}
      end
    else
      return "WRONG DIMENSIONS"
    end
  end
  
  def boundaries
    self.content.values
  end
  
  def generate_sample_points(rows, save_raw_data = false)
    raw_data = Estimation::RawData.factory(rows: rows, cols: size)
    #raw_data.save if save_raw_data
    map_normals(raw_data)
  end
  
  def size
    self.content.length
  end
  
  private 

  def map_normal_to_sample_point(normal, range_array)
    range = range_array[1] - range_array[0]
    range_array[0] + range * normal
  end
  
  def check_dims(space1, space2)
    space1 == space2 ? true : false
  end
  

  
end
