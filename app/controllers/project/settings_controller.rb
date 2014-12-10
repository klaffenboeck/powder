class Project::SettingsController < ApplicationController
  before_action :set_project_setting, only: [:show]
  before_action :load_measured_points, only: [:index]

  # GET /project/settings, momentarily root
  def index
    @project_settings = Project::Setting.all
  end

  # GET /project/settings/{id}
  def show
  end

  def remotecall
    render json: Project::Setting.first
  end

  def remotepost
    parameters = project_setting_params
    p parameters
    p parameters.keys
    #p params[:parameters]
    render json: Project::Setting.first
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
