class AddDataAnglesToSettings < ActiveRecord::Migration
  def change
    add_reference :project_settings, :data_angles, index: true
  end
end
