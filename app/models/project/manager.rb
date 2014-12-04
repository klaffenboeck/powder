require "forwardable"

class Project::Manager
  include ActiveModel::Model
  extend Forwardable
  attr_accessor :setting, :raw_data, :input_params_list, :function, :function_run_list #, :executable, :measured_points, , :parameter_space, , :run_list
  
  def_delegators :@setting, :executable, :measured_points, :parameter_space, :run_list, :estimation_function
  
  class << self
    def factory(setting)
      setting = Project::Setting.find(setting) if setting.is_a?(Fixnum)
      manager = new
      manager.setting = setting
      # manager.executable = setting.executable
      # manager.measured_points = setting.measured_points
      # manager.parameter_space = setting.parameter_space
      manager
    end
    
    alias_method :setup, :factory
  end
  
  def generate_estimation_function(type = "GaussianProcessModel")
    function = ("Estimation::Function::" + type).constantize.new(project_setting: setting)
    function.raw_data = generate_raw_data
    generate_input_params_list
    function.run_list = generate_function_run_list
    R.input_matrix = function.run_list.input_matrix
    R.result_vector = function.run_list.result_vector
    R.eval "output <- mlegp(input_matrix, result_vector)"
    rd = function.raw_data
    rd.mu = R.pull "output$mu"
  end

  def generate_raw_data
    self.raw_data = Estimation::RawData.factory(cols: parameter_space.size, rows: setting.accuracy)
  end
  
  def generate_input_params_list(input_raw_data = nil)
    rd = input_raw_data || self.raw_data
    self.input_params_list = MathModel::InputParamsList.factory(raw_data: rd, parameter_space: parameter_space)
    #return "TEST"
  end
  
  def generate_function_run_list(var_input_params_list = nil)
    ipl = var_input_params_list || self.input_params_list
    self.function_run_list = ipl.create_run_list(self.setting)
  end
  
  def run(input_params, position = nil)
    executable.run(input_params, setting, position)
  end
  
  def estimation_function
    setting.estimation_function
  end
  
  def estimation_function=(func)
    setting.estimation_function = func
  end
  
end