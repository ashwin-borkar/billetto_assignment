module ErrorReporting
  class << self
    def notify(exception)
      # Integration with error reporting service (like Sentry, Bugsnag, etc.)
      Rails.logger.error "Exception reported: #{exception.class.name}: #{exception.message}"
      Rails.logger.error exception.backtrace.join("\n")
      
      # In production, this would integrate with external error reporting
      if defined?(Sentry)
        Sentry.capture_exception(exception)
      end
    end
  end
end
