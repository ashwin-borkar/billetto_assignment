class IncomingWebhook < ApplicationRecord
  validates :service, presence: true
  validates :data, presence: true

  def handled?
    handled_at.present?
  end

  def mark_as_handled(timestamp, result)
    update!(handled_at: timestamp, result: result)
  end
end
