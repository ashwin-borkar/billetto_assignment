class ApplicationSubscriptions
  def self.handlers
    top_level_subscriptions
      .merge(Events.subscriptions)
      .merge(Guidelines.subscriptions)
      .merge(GuidelinesIntegrators.subscriptions)
      .merge(ReadModels::NumberOfRfcIssuedByDeveloper.subscriptions)
  end

  def self.top_level_subscriptions
    # Add any top-level subscriptions here
    {}
  end
end
