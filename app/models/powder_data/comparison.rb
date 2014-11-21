class PowderData::Comparison < ActiveRecord::Base
  belongs_to :measured_points
  belongs_to :emulated_points
end
