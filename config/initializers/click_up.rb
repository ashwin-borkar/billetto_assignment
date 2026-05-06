Rails.configuration.to_prepare do
  # Setup ClickUp adapter for each environment
  Rails.configuration.clickup = ClickUp::Adapter.new(
    api_key: Rails.application.credentials.dig(:click_up, :api_key)
  )
end
