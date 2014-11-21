class AddMeasuredPointsToProjectSetting < ActiveRecord::Migration
  def change
    add_column :project_settings, :measured_points_id, :integer
  end
end
