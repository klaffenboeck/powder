class CreatePowderDataEmulatedPoints < ActiveRecord::Migration
  def change
    create_table :powder_data_emulated_points do |t|
      t.text :points

      t.timestamps
    end
  end
end
