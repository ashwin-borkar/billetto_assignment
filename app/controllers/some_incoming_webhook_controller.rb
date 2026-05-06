class SomeIncomingWebhookController < ApplicationController
  def create
    payload = JSON.parse(request.body.read, symbolize_names: true)
    
    IncomingWebhook.create!(service: "some_service", data: payload.to_h).tap do |webhook|
      SomeServiceWebhookJob.perform_async(webhook.id)
    end
    
    head :created
  rescue SomeService::Error => exc
    ErrorReporting.notify(exc)
    head :bad_request
  end
end
