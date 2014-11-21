class CreatePowderDataComparisons < ActiveRecord::Migration
  def change
    create_table :powder_data_comparisons do |t|
      t.text :points
      t.references :measured_points, index: true
      t.references :emulated_points, index: true

      t.timestamps
    end
  end
end
