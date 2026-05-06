require_relative 'events/voting_events'

module Events
  def self.subscriptions
    [
    ].map(&:subscriptions).reduce(&:merge)
  end
end
