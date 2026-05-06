class ImportEventsJob < ApplicationJob
  queue_as :default
  
  def perform
    ##AS OF NOW NOT ADDED THE BILLETTO API KEY 
    api_key = Rails.application.credentials.billetto&.dig(:api_key)
    return unless api_key
    
    client = Billetto::Client.new(api_key)
    events_data = client.fetch_events
    events_data.each do |event_data|
      begin
        event = Event.from_billetto_data(event_data)
        event.save! if event.changed?
      rescue => e
        Rails.logger.error "Failed to import event #{event_data[:id]}: #{e.message}"
      end
    end
  end
end
