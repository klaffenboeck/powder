class Frontend::ExplorationsController < ApplicationController
  before_action :set_frontend_exploration, only: [:show, :edit, :update, :destroy]

  # GET /frontend/explorations
  # GET /frontend/explorations.json
  def index
    @frontend_explorations = Project::Setting.all
  end

  # GET /frontend/explorations/1
  # GET /frontend/explorations/1.json
  def show
  end

  # GET /frontend/explorations/new
  def new
    @frontend_exploration = Frontend::Exploration.new
  end

  # GET /frontend/explorations/1/edit
  def edit
  end

  # POST /frontend/explorations
  # POST /frontend/explorations.json
  def create
    @frontend_exploration = Frontend::Exploration.new(frontend_exploration_params)

    respond_to do |format|
      if @frontend_exploration.save
        format.html { redirect_to @frontend_exploration, notice: 'Exploration was successfully created.' }
        format.json { render :show, status: :created, location: @frontend_exploration }
      else
        format.html { render :new }
        format.json { render json: @frontend_exploration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /frontend/explorations/1
  # PATCH/PUT /frontend/explorations/1.json
  def update
    respond_to do |format|
      if @frontend_exploration.update(frontend_exploration_params)
        format.html { redirect_to @frontend_exploration, notice: 'Exploration was successfully updated.' }
        format.json { render :show, status: :ok, location: @frontend_exploration }
      else
        format.html { render :edit }
        format.json { render json: @frontend_exploration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /frontend/explorations/1
  # DELETE /frontend/explorations/1.json
  def destroy
    @frontend_exploration.destroy
    respond_to do |format|
      format.html { redirect_to frontend_explorations_url, notice: 'Exploration was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_frontend_exploration
      @frontend_exploration = Project::Setting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def frontend_exploration_params
      params[:frontend_exploration]
    end
end
