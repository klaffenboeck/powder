require "forwardable"

class Project::Manager
  include ActiveModel::Model
  include ActiveModel::SerializerSupport
  include SerialExt
  extend Forwardable
  attr_accessor :setting, :raw_data, :input_params_list, :function, :function_run_list #, :executable, :measured_points, , :parameter_space, , :run_list
  
  def_delegators :@setting, :executable, :measured_points, :data_angles, :parameter_space, :run_list, :estimation_function
  
  class << self
    def factory(setting)
      setting = Project::Setting.find(setting) if setting.is_a?(Fixnum)
      manager = new
      manager.setting = setting
      manager
    end
    
    alias_method :setup, :factory
  end
  

  ##
  # Complete method commented out, can't remember why!
  #
  def generate_estimation_function(type = "GaussianProcessModel")
    # function = ("Estimation::Function::" + type).constantize.new(project_setting: setting)
    # function.raw_data = generate_raw_data
    # generate_input_params_list
    # function.run_list = generate_function_run_list
    # R.input_matrix = function.run_list.input_matrix
    # R.result_vector = function.run_list.result_vector
    # R.eval "output <- mlegp(input_matrix, result_vector)"
    # rd = function.raw_data
    # rd.mu = R.pull "output$mu"
  end


  ##
  # generate and store (not save!) the raw data
  # return raw_data [Estimation::RawData]
  #
  def generate_raw_data
    self.raw_data = Estimation::RawData.factory(cols: parameter_space.size, rows: setting.accuracy)
  end
  

  ## 
  # generate and store (not save!) the input params list
  #
  # @overload generate_input_params_list
  #   Uses the internally stored #raw_data and creates the input_params_list
  #   @return input_params_list [MathModel::InputParamsList]
  # @overload generate_input_params_list(input_raw_data)
  #   Uses the passed input_raw_data to create the input_params_list
  #   @param input_raw_data [Estimation::RawData]
  #   @return generate_input_params_list(input_raw_data)
  #
  def generate_input_params_list(input_raw_data = nil)
    rd = input_raw_data || self.raw_data
    self.input_params_list = MathModel::InputParamsList.factory(raw_data: rd, parameter_space: parameter_space)
  end
  
  def generate_function_run_list(var_input_params_list = nil)
    ipl = var_input_params_list || self.input_params_list
    self.function_run_list = ipl.create_run_list(self.setting)
  end
  
  def run(input_params, position = nil)
    input_params = correct_params(input_params)
    run = executable.run(input_params, setting, position)
  end
  
  def estimation_function
    setting.estimation_function
  end
  
  def estimation_function=(func)
    setting.estimation_function = func
  end

  def get_json()

  end

  def correct_params(params, type = nil)
    type = executable.paramstype if type.nil?
    return params if params.class.to_s == type.capitalize
    parameter_space.send("input_" + type.downcase, params)
  end

  def get_merged_run_list
    MathModel::RunList.merge(setting.run_list, estimation_function.run_list)
  end
  
end













