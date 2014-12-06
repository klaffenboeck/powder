# == Project::Executable
# a method class

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
    return MathModel::Run.new(input_params: params, result: result, project_setting: setting) if result.is_a?(MathModel::Result)
    return MathModel::Run.new(input_params: params, emulated_points: result, project_setting: setting) if result.is_a?(PowderData::EmulatedPoints)
  end
  
  private
  

  # TODO must also work with adapter class, not only string
  def init_adapter
    self.adapter = adapter_string.constantize.new
  end
  
end
