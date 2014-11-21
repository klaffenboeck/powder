class Project::Executable < ActiveRecord::Base
  attr_accessor :adapter
  has_many :settings, class_name: "Project::Setting"
  after_initialize :init_adapter
  class << self
    def factory(string, adapter = nil)
      exec = new({command: string, adapter_string: get_adapter(adapter)})
      return exec
    end
    
    def get_adapter(adapter)
      adapter.nil? ? "MathModel::Adapter::Mathematica" : adapter
    end
  end
  
  def run(params, setting = nil, pos = nil)
    result = adapter.execute(command, params, pos)
    MathModel::Run.new(input_params: params, result: result, project_setting: setting)
  end
  
  private
  
  def init_adapter
    self.adapter = adapter_string.constantize.new
  end
  
end
