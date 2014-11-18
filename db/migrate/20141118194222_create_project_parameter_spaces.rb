class CreateProjectParameterSpaces < ActiveRecord::Migration
  def change
    create_table :project_parameter_spaces do |t|
      t.text :content

      t.timestamps
    end
  end
end
