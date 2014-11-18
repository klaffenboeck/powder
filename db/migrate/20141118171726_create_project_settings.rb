class CreateProjectSettings < ActiveRecord::Migration
  def change
    create_table :project_settings do |t|
      t.string :name
      t.text :description
      t.integer :accuracy
      t.references :executable, index: true
      t.references :parameter_space, index: true
      t.string :adapter

      t.timestamps
    end
  end
end
