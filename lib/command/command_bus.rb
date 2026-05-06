module Command
  class CommandBus
    class << self
      def executable_commands
        @executable_commands ||= {}
      end

      def handlers
        @handlers ||= {}
      end

      def register_executable_command(command_class)
        executable_commands[command_class.name] = command_class
      end

      def register_handler(command_class, handler_class, method_name)
        handlers[command_class.name] = { handler: handler_class, method: method_name }
      end

      def call(command)
        command_class_name = command.class.name
        
        if executable_commands.key?(command_class_name)
          execute_with_transaction(command) do
            command.call
          end
        elsif handlers.key?(command_class_name)
          handler_info = handlers[command_class_name]
          handler = handler_info[:handler].new
          execute_with_transaction(command) do
            handler.send(handler_info[:method], command)
          end
        else
          raise ArgumentError, "No handler registered for command: #{command_class_name}"
        end
      end

      private

      def execute_with_transaction(command)
        ActiveRecord::Base.transaction do
          # Set up causation and correlation IDs if in event handler context
          result = yield
          
          # Log successful command execution
          Rails.logger.info "Command executed successfully: #{command.class.name}"
          result
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Validation failed for command #{command.class.name}: #{e.message}"
        ErrorReporting.notify(e)
        raise e
      rescue => e
        Rails.logger.error "Command execution failed: #{command.class.name} - #{e.message}"
        ErrorReporting.notify(e)
        raise e
      end
    end
  end
end
