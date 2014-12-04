class AddRawDataToEstimationFunction < ActiveRecord::Migration
  def change
    add_reference :estimation_functions, :raw_data, index: true
  end
end
