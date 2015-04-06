

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
  
  # get the boundaries of the parameter space
  # @return Array of Arrays
  def boundaries
    self.content.values
  end
  
  def generate_sample_points(rows, save_raw_data = false)
    p "GENERATE SAMPLE POINTS"
    raw_data = Estimation::RawData.factory(rows: rows, cols: size)
    #raw_data.save if save_raw_data
    map_normals(raw_data)
  end
  
  # returns the size of the parameter space
  # @return Fixnum
  def size
    self.content.length
  end

  alias_method :length, :size

  # get the keys of the hash stored in content
  # @return Array of Strings
  def keys
    self.content.keys
  end

  # create and return an ordered array with your inputs
  # @param hash Hash
  # @return Array
  def input_array(hash)
    self.keys.map {|key| hash[key].to_f}
  end

  def input_hash(array)
    hash = {}
    counter = 0
    self.keys.each {|key, val| hash[key] = array[counter]; counter += 1}
    return hash
  end

  alias_method :to_array, :input_array
  alias_method :to_input_array, :input_array
  
  private 

  def map_normal_to_sample_point(normal, range_array)
    range = range_array[1] - range_array[0]
    range_array[0] + range * normal
  end
  
  def check_dims(space1, space2)
    space1 == space2 ? true : false
  end
  

  
end
