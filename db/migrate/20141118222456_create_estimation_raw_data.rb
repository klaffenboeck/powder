class CreateEstimationRawData < ActiveRecord::Migration
  def change
    create_table :estimation_raw_data do |t|
      t.text :normal_sample_point_matrix
      t.decimal :mu
      t.decimal :theta
      t.text :inv_var_matrix
      t.decimal :sig2

      t.timestamps
    end
  end
end
