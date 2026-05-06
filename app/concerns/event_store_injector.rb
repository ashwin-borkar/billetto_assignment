module EventStoreInjector
  extend ActiveSupport::Concern

  included do
    before_validation :generate_tid, on: :create
  end

  private

  def generate_tid
    self.tid ||= "#{self.class.name.demodulize}$#{SecureRandom.uuid}"
  end

  def event_store
    Rails.application.event_store
  end

  def command_bus
    Rails.application.command_bus
  end
end
