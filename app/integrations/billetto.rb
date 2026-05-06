module Billetto
  class ApiError < StandardError; end
  
  class Client
    include HTTParty
    
    base_uri 'https://api.billetto.com'
    
    def initialize(api_key)
      @api_key = api_key
    end
    
    def fetch_events
      response = self.class.get('/v1/events/public', {
        headers: {
          'Authorization' => "Bearer #{@api_key}",
          'Content-Type' => 'application/json'
        }
      })
      
      unless response.success?
        raise ApiError, "Failed to fetch events: #{response.code} - #{response.message}"
      end
      
      response.parsed_response
    end
    
    def fetch_event(event_id)
      response = self.class.get("/v1/events/#{event_id}", {
        headers: {
          'Authorization' => "Bearer #{@api_key}",
          'Content-Type' => 'application/json'
        }
      })
      
      unless response.success?
        raise ApiError, "Failed to fetch event: #{response.code} - #{response.message}"
      end
      
      response.parsed_response
    end
  end
end
