class CreateMathModelRunLists < ActiveRecord::Migration
  def change
    create_table :math_model_run_lists do |t|
      t.references :run_list_holder, polymorphic: true

      t.timestamps
    end
  end
end
