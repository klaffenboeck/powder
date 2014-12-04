class AddReferenceToMathModelRun < ActiveRecord::Migration
  def change
    add_reference :math_model_runs, :emulated_points, index: true
    add_reference :math_model_runs, :comparisons, index: true
  end
end
