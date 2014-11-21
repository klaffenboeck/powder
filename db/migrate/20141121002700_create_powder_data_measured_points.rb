class CreatePowderDataMeasuredPoints < ActiveRecord::Migration
  def change
    create_table :powder_data_measured_points do |t|
      t.text :points

      t.timestamps
    end
  end
end
