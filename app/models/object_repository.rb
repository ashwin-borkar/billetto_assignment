class ObjectRepository
  class << self
    def registered_objects
      @registered_objects ||= {}
    end

    def register(domain_class)
      registered_objects[domain_class.name] = domain_class
    end

    def find(tid)
      # Parse the type from the typeid and find the appropriate object
      type_id = tid.split('$').first
      
      # Try exact match first
      domain_class = registered_objects[type_id]
      
      # If not found, try with full class name
      if domain_class.nil?
        domain_class = registered_objects.values.find do |klass|
          klass.name.split('::').last == type_id
        end
      end
      
      raise ArgumentError, "Unknown domain type: #{type_id}" unless domain_class
      
      domain_class.find_by(tid: tid)
    end
  end
end
