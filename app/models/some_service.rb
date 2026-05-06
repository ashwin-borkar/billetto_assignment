module SomeService
  class Error < StandardError; end
  
  # Example service integration
  class Client
    def initialize(api_key:)
      @api_key = api_key
    end

    def process_webhook(data)
      # Implementation for processing webhook data
      raise Error, "Invalid webhook data" unless data.present?
      
      # Process the webhook
      true
    end
  end
end
