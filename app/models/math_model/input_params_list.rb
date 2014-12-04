require 'forwardable'

class MathModel::InputParamsList
  include ActiveModel::Model
  attr_accessor :list_of_params
  extend Forwardable
  
  def self.factory(params = {})
    list = new
    raw_data = params[:raw_data]
    parameter_space = params[:parameter_space]
    mapped = parameter_space.map_normals(raw_data)
    mapped.each do |input|
      list.list_of_params.push(MathModel::InputParams.new({params: input}))
    end
    list
  end
  
  def_delegators :@list_of_params, :length, :size, :each, :each_with_index, :map, :collect

  def initialize(attributes = {})
    super
    self.list_of_params = []
  end
  
  def create_run_list(setting)
    exec = setting.executable
    run_list = MathModel::RunList.new
    each do |input|
      run = exec.run(input, setting)
      run_list.add(run)
    end
    return run_list
  end
  
  private 
  
  def extract_params(obj)
    return obj.normal_sample
  end
end