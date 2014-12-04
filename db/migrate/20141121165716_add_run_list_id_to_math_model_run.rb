class AddRunListIdToMathModelRun < ActiveRecord::Migration
  def change
    add_reference :math_model_runs, :run_list
  end
end
