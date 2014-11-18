class CreateProjectExecutables < ActiveRecord::Migration
  def change
    create_table :project_executables do |t|
      t.string :command

      t.timestamps
    end
  end
end
