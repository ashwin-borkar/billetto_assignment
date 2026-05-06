module Command
  module Executable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def inherited(subclass)
        super
        CommandBus.register_executable_command(subclass)
      end
    end

    def call
      # Override in subclasses
      raise NotImplementedError, "Command must implement #call method"
    end
  end

  module Handler
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def handles(command_class, method_name)
        CommandBus.register_handler(command_class, self, method_name)
      end
    end
  end

  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    def call
      raise NotImplementedError, "Command must implement #call method"
    end
  end
end
