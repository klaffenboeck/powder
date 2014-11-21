class ChangeColumnNameMathModelRun < ActiveRecord::Migration
  def change
    rename_column :math_model_runs, :project_settings_id, :project_setting_id
  end
end
