class PowderData::QualityMetric < ActiveRecord::Base
  belongs_to :math_model_run
  
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end
