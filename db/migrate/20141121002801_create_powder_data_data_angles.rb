class CreatePowderDataDataAngles < ActiveRecord::Migration
  def change
    create_table :powder_data_data_angles do |t|
      t.text :angles

      t.timestamps
    end
  end
end
