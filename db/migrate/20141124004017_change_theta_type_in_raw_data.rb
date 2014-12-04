class ChangeThetaTypeInRawData < ActiveRecord::Migration
  def self.up
    change_column :estimation_raw_data, :theta, :text
  end

  def self.down
    change_column :estimation_raw_data, :theta, :decimal
  end
end
