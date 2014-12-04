require 'forwardable'

class MathModel::RunList < ActiveRecord::Base
  belongs_to :run_list_holder, polymorphic: true
  has_many :runs, class_name: "MathModel::Run", dependent: :destroy
  
  delegate :measured_points, :adapter, to: :run_list_holder
  attr_accessor :temp_adapter
  
  extend Forwardable
  
  class << self
    def factory(content)
      return from_input_params_list(content) if content.is_a?(MathModel::InputParamsList)
    end
    
    private 
    
    def from_input_params_list(input_params_list)
      
    end
  end
  
  public
  
  def_delegators :@runs, :length, :size, :each, :each_with_index, :map, :collect # , :[], :first, :last
  
  
  def add(run)
    raise Exceptions::TypeMismatch if !run.is_a?(MathModel::Run)
    self.runs << run
  end

  def input_matrix
    arr = runs.map do |run|
      #byebug
      run.input_params.respond_to?(:params) ? run.input_params.params : run.input_params["params"]
    end
    Matrix.rows(arr)
  end

  def result_vector(type = "Chi2")
    typ = type || "Chi2"
    arr = []
    collection = MathModel::Run.where(run_list_id: self.id).includes(:quality_metrics).where(powder_data_quality_metrics: {type: "PowderData::QualityMetric::Chi2"})
    collection.each do |run|
      arr.push(run.quality_metrics.first.scalar)
    end
    arr
  end

  def calculate_quality_metrics
    runs.each {|run| run.calculate_quality_metric}
  end

  
end