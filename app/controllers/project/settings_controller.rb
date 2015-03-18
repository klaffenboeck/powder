class Project::SettingsController < ApplicationController
  before_action :set_project_setting, only: [:show]
  before_action :load_measured_points, only: [:index]

  # GET /project/settings, momentarily root
  def index
    @project_settings = Project::Setting.all
    @testpoints = PowderData::EmulatedPoints.last
  end

  # GET /project/settings/{id}
  def show
    @manager = Project::Manager.setup(@project_setting)
    @testpoints = PowderData::EmulatedPoints.last
    @function = @project_setting.estimation_function.serialize.as_json
  end

  def remotecall
    @setting = Project::Setting.find(params[:id])
    render json: @setting
  end

  # currently the method to get the data into fronted via ajax
  # should be exchanged actually for something more appropriate
  # TODO: change name of call, add new route, delete old one (probably)
  # TODO: calculation of quality metrics has to be changed (shouldn't happen in controller)
  def remotepost
    parameters = project_setting_params
    inputvals = parameters
    id = params[:id].to_i
    manager = Project::Manager.setup(id)
    run = manager.run(inputvals)
    manager.run_list.add(run)
    run.calculate_quality_metric
    #render json: run.get_emulated_points.to_json
    render json: run
  end

  def alternative_estfunc
    #parameters = project_setting_params
    result_vector = params[:parameters]
    rv = result_vector.map do |r|
      r = r.to_f
    end
    id = params[:id].to_i
    manager = Project::Manager.setup(id)
    func = manager.estimation_function
    newfunc = func.create_alternative(rv)
    render json: newfunc
  end

  def get_runs
    manager = Project::Manager.setup(params[:id].to_i)
    runs = manager.run_list.runs
    render json: runs, root: "runs"
  end

  def get_initial_runs
    manager = Project::Manager.setup(params[:id].to_i)
    runs = manager.estimation_function.run_list.runs
    render json: runs, root: "initial_runs"
  end

  private 

  def set_project_setting
    @project_setting = Project::Setting.find(params[:id])
  end

  def load_measured_points
    @project_setting = Project::Setting.last
  end

  def project_setting_params
    params.require(:parameters).permit!
    #params[:project_setting]
  end

  def result_vector_params
    params.require(:result_vector).permit!
  end
end
