module Guidelines
  class RfcNumberGenerator
    def call
      "RFC-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
    end
  end
end
