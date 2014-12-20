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
    render json: Project::Setting.first
  end

  # currently the method to get the data into fronted via ajax
  # should be exchanged actually for something more appropriate
  # TODO: change name of call, add new route, delete old one (probably)
  def remotepost
    parameters = project_setting_params
    inputvals =  parameters.values.map {|v| v.to_f}
    id = params[:id].to_i
    #setting = Project::Setting.find(id)
    manager = Project::Manager.setup(id)
    run = manager.run(inputvals)
    render json: run.get_emulated_points.to_json
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
end
