class CreatePowderDataQualityMetrics < ActiveRecord::Migration
  def change
    create_table :powder_data_quality_metrics do |t|
      t.decimal :value
      t.string :type
      t.references :math_model_run, index: true

      t.timestamps
    end
  end
end
