module ClickUp
  # Domain events published by the integration
  class TaskCreated < RailsEventStore::Event
    SCHEMA = {
      task_id: String,
      name: String,
      description: String,
    }.freeze

    def stream_names
      ["ClickUp$#{data.fetch(:task_id)}"]
    end
  end

  # Commands to trigger actions on ClickUp API
  class AddNewTaskToTheBacklog < Command::Base
    attribute :name, String
    attribute :description, String
    attribute :priority, String
    
    validates :name, :description, presence: true
  end

  # Error classes to not allow 3rd party errors to bubble up
  class Error < StandardError; end
  class ApiError < Error; end
  class AuthenticationError < Error; end
end
