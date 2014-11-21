class PowderData::DataAngles < ActiveRecord::Base
  serialize :angles, JSON
end
