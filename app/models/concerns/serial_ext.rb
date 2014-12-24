module SerialExt
  # extend ActiveSupport::Concern
  module ClassMethods
    
  end

  
  module InstanceMethods

    # invokes the serializer for the object, needed for custom json
    def serialize
      (self.class.name + "Serializer").constantize.new(self)
    end
  end
  
  # old way, now covered by active support concern
  # but havent gotten concern to work yet, tbd later
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end