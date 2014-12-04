class CreateEstimationFunctions < ActiveRecord::Migration
  def change
    create_table :estimation_functions do |t|
      t.text :content
      t.string :type
      t.references :project_setting, index: true

      t.timestamps
    end
  end
end
