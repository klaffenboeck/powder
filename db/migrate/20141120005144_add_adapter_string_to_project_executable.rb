class AddAdapterStringToProjectExecutable < ActiveRecord::Migration
  def change
    add_column :project_executables, :adapter_string, :string
  end
end
