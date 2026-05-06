module Guidelines
  class IssueRequestForComment < Command::Base
    attribute :description, String
    attribute :developer_id, String
    
    validates :description, :developer_id, presence: true
  end
end
