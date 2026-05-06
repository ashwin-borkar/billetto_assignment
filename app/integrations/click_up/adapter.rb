module ClickUp
  class Adapter
    def initialize(api_key:)
      @api_key = api_key
      @base_url = "https://api.clickup.com/api/v2"
    end

    def create_task(name:, description:, priority: "medium")
      # Implementation for ClickUp API
      response = HTTP.auth("Bearer #{@api_key}")
                     .post("#{@base_url}/list/#{list_id}/task", json: {
                       name: name,
                       description: description,
                       priority: priority
                     })
      
      raise ApiError, "Failed to create task: #{response.status}" unless response.success?
      
      JSON.parse(response.body)
    rescue HTTP::Error => e
      raise ApiError, "Network error: #{e.message}"
    end

    private

    attr_reader :api_key, :base_url

    def list_id
      # Configure this based on your ClickUp setup
      Rails.application.credentials.dig(:click_up, :list_id)
    end
  end
end
