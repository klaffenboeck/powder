class CreateFrontendExplorations < ActiveRecord::Migration
  def change
    create_table :frontend_explorations do |t|

      t.timestamps
    end
  end
end
