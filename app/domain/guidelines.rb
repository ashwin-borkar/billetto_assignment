module Guidelines
  def self.subscriptions
    [
      RfcApprovalProcess,
    ].map(&:subscriptions).reduce(&:merge)
  end

  class RfcIssued < RailsEventStore::Event
    SCHEMA = {
      tid: String,
      developer_id: String,
      number: String,
    }.freeze

    def stream_names
      ["RFC$#{data.fetch(:tid)}"]
    end
  end

  class RfcApprovedByDeveloper < RailsEventStore::Event
    SCHEMA = {
      tid: String,
      developer_id: String,
    }.freeze

    def stream_names
      ["RFC$#{data.fetch(:tid)}", "Developer$#{data.fetch(:developer_id)}"]
    end
  end

  class RfcApproved < RailsEventStore::Event
    SCHEMA = {
      tid: String,
    }.freeze

    def stream_names
      ["RFC$#{data.fetch(:tid)}"]
    end
  end
end
