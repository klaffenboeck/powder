require 'forwardable'

class MathModel::RunList < ActiveRecord::Base
  include SerialExt
  belongs_to :run_list_holder, polymorphic: true
  has_many :runs, class_name: "MathModel::Run", dependent: :destroy
  
  delegate :measured_points, :adapter, to: :run_list_holder
  attr_accessor :temp_adapter
  
  extend Forwardable
  
  class << self

    ##
    # factory for the {MathModel::RunList}
    # @note honestly, I don't know what I do here, because this calls an empty method
    # OPTIMIZE: figure out, if this method is used at all!!
    #
    def factory(content)
      return from_input_params_list(content) if content.is_a?(MathModel::InputParamsList)
    end


    ##
    # merge two run lists together and get a new run list
    #
    # @param run_list_1 [MathModel::RunList] first run_list (e.g. setting)
    # @param run_list_2 [MathModel::RunList] second run_list (e.g. function)
    # @return merged [MathModel::RunList] the merged run_list
    # 
    def merge(run_list_1, run_list_2)
      merged = new
      run_list_1.runs.each {|run| p merged.add(run) }
      run_list_2.runs.each {|run| p merged.add(run) }
      return merged
    end
    
    private 
    
    ##
    # What the hell...
    #
    def from_input_params_list(input_params_list)
      
    end
  end
  
  public
  
  def_delegators :@runs, :length, :size, :each, :each_with_index, :map, :collect # , :[], :first, :last
  

  ##
  # add a run to the run_list
  # @param run [MathModel::Run] the run to be added
  # @throws [Exceptions::TypeMismatch] if run is not of type {MathModel::Run}
  #
  def add(run)
    p run.class.to_s
    raise Exceptions::TypeMismatch if !run.is_a?(MathModel::Run)
    self.runs << run
  end


  ##
  # get the according matrix for this run list
  #
  # @return [Matrix] matrix according to the run list
  # @note this method is buggy as hell and needs to be improved!!
  # @note input_params can either be a hash or an array - that's very bad design and should definitely be improved!!
  # FIXME: very buggy method, needs improvement!!
  # @deprecated Most likely! Use {#get_input_matrix} for the moment!
  #
  def input_matrix
    warn "[DEPRECATED] - use get_input_matrix (althought this one also still might need improvement!)"
    arr = runs.map do |run|
      run.input_params.respond_to?(:params) ? run.input_params.params : run.input_params["params"]
    end
    Matrix.rows(arr)
  end


  ## 
  # get the according matrix for this run list, refactored
  # @note although already refactored, this should be overhauled. 
  #   More specific, the {MathModel::InputParams} should be revisited, because they are responsible for that mess!!
  # @see #input_matrix
  #
  def get_input_matrix
    arr = self.runs.map do |run|
      params = run.input_params
      case params
      when Array 
        params
      when Hash 
        params["params"]
      end
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