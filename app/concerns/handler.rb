module Handler
  extend ActiveSupport::Concern

  module ClassMethods
    def subscribes_to(event_class)
      @subscribed_events ||= []
      @subscribed_events << event_class
    end

    def async(queue: "default")
      @async_queue = queue
    end

    def subscriptions
      return {} unless @subscribed_events

      @subscribed_events.each_with_object({}) do |event_class, subscriptions|
        stream_names = event_class.new(data: {}).stream_names
        stream_names.each do |stream_name|
          subscriptions[stream_name] = {
            handler: self,
            async: @async_queue.present?,
            queue: @async_queue || "default"
          }
        end
      end
    end
  end

  def call(event)
    raise NotImplementedError, "Handler must implement #call method"
  end

  def event_store
    Rails.application.event_store
  end

  def command_bus
    Rails.application.command_bus
  end
end
