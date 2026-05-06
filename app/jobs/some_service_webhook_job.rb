class SomeServiceWebhookJob
  Error = Class.new(StandardError)
  
  include Sidekiq::Worker
  sidekiq_options queue: "critical"

  def perform(webhook_id)
    IncomingWebhook.find(webhook_id).tap do |webhook|
      return if webhook.handled?
      
      handled = call(webhook.data.with_indifferent_access)
      webhook.mark_as_handled(Time.zone.now, handled)
    end
  rescue => e
    raise Error, "Failed to process webhook: #{e.message}"
  end

  private

  def call(data)
    # ... handle logic here
    true
  end
end
