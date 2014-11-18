class CreateMathModelRuns < ActiveRecord::Migration
  def change
    create_table :math_model_runs do |t|
      t.text :input_params
      t.text :result
      t.references :project_settings, index: true
      t.boolean :show

      t.timestamps
    end
  end
end
