class Project::Manager
  include ActiveModel::Model
  attr_accessor :setting, :executable, :measured_points, :raw_data, :parameter_space, :input_params_list, :run_list
  
  class << self
    def factory(setting)
      manager = new
      manager.setting = setting
      manager.executable = setting.executable
      manager.measured_points = setting.measured_points
      manager.parameter_space = setting.parameter_space
      manager
    end
    
    alias_method :setup, :factory
  end
  
  def generate_raw_data
    self.raw_data = Estimation::RawData.factory(cols: parameter_space.size, rows: setting.accuracy)
  end
  
  def generate_input_params_list(input_raw_data = nil)
    rd = input_raw_data || self.raw_data
    self.input_params_list = MathModel::InputParamsList.factory(raw_data: rd, parameter_space: parameter_space)
    #return "TEST"
  end
  
  def generate_run_list(var_input_params_list = nil)
    ipl = var_input_params_list || self.input_params_list
    self.run_list = ipl.create_run_list(self.setting)
  end
  
  def run(input_params, position = nil)
    executable.run(input_params, setting, position)
  end
end