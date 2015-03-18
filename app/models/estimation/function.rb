class Estimation::Function < ActiveRecord::Base
  #alias_attribute :setting_id, :project_setting_id
  include SerialExt
  belongs_to :project_setting, class_name: "Project::Setting"
  belongs_to :raw_data, class_name: "Estimation::RawData", dependent: :destroy
  has_one :run_list, as: :run_list_holder, class_name: "MathModel::RunList", dependent: :destroy
  attr_accessor :input_params_list, :result_vector, :corr_response, :inv_var_matrix
  attr_writer :mu, :sig2, :theta
  after_initialize :further_setup

  delegate :measured_points, :parameter_space, :adapter, to: :project_setting
  delegate :mu, :sig2, :theta, to: :raw_data
  delegate :input_matrix, to: :run_list
  

  class << self
    def factory(setting)
      func = new(project_setting: setting)
      self.transaction do
        func.generate_raw_data
        func.save
        func.generate_input_params_list
        func.generate_run_list
        func.save
        func.run_list.calculate_quality_metrics

        # R.matrix = func.run_list.input_matrix
        # R.result = func.run_list.result_vector
        # R.eval "output <- mlegp(matrix, result)"
        # func.raw_data.mu = R.pull("output$mu")[0,0]
        # func.raw_data.sig2 = R.pull("output$sig2")
        # func.raw_data.inv_var_matrix = R.pull("output$invVarMatrix")
        # func.raw_data.theta = R.pull("output$beta")

        conn = Rserve::Connection.new
        conn.eval("library(mlegp);")
        r_matrix = Rserve::REXP::Wrapper.wrap(func.run_list.input_matrix)
        r_vector = Rserve::REXP::Wrapper.wrap(func.run_list.result_vector)
        conn.assign("matrix", r_matrix)
        conn.assign("vector", r_vector)
        output = conn.eval("output <- mlegp(matrix, vector)")
        r_output = output.to_ruby
        func.raw_data.mu = r_output["mu"][0,0]
        func.raw_data.sig2 = r_output["sig2"]
        func.raw_data.inv_var_matrix = r_output["invVarMatrix"]
        func.raw_data.theta = r_output["beta"]


        func.save
        func.raw_data.save
      end
      return func
    end
  end

  def create_alternative(result_vector)
    p "BEFORE CONN"
    conn = Rserve::Connection.new
    p "AFTER CONN"
    conn.eval("library(mlegp);")
    p "AFTER MLEGP"
    r_matrix = Rserve::REXP::Wrapper.wrap(self.run_list.input_matrix)
    r_vector = Rserve::REXP::Wrapper.wrap(result_vector)
    p "BEFORE ASSIGNMENTS"
    conn.assign("matrix", r_matrix)
    conn.assign("vector", r_vector)
    p "AFTER ASSIGNMENTS"
    p result_vector
    output = conn.eval("output <- mlegp(matrix, vector)")
    p "AFTER OUTPUT"
    r_output = output.to_ruby
    self.raw_data.mu = r_output["mu"][0,0]
    self.raw_data.sig2 = r_output["sig2"]
    self.raw_data.inv_var_matrix = r_output["invVarMatrix"]
    self.raw_data.theta = r_output["beta"]
    return self
  end


  def generate_raw_data
    self.raw_data = Estimation::RawData.factory(cols: parameter_space.size, rows: project_setting.accuracy)
  end
  
  def generate_input_params_list(input_raw_data = nil)
    rd = input_raw_data || self.raw_data
    self.input_params_list = MathModel::InputParamsList.factory(raw_data: rd, parameter_space: parameter_space)
    #return "TEST"
  end
  
  def generate_run_list(var_input_params_list = nil)
    ipl = var_input_params_list || self.input_params_list
    rl = ipl.create_run_list(project_setting)
    self.run_list = rl
  end

  def further_setup
    #self.input_matrix = Matrix.rows(run_list.input_matrix)
    self.inv_var_matrix = Matrix.rows(raw_data.inv_var_matrix) if !!raw_data && !!raw_data.inv_var_matrix
    self.result_vector = Vector.elements(run_list.result_vector) if !!run_list && !!run_list.result_vector
  end

  # def serialize
  #   (self.class.name + "Serializer").constantize.new(self)
  # end
end
