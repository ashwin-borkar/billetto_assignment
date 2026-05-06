module Guidelines
  class ApproveRequestForComment < Command::Base
    attribute :tid, String
    
    validates :tid, presence: true
  end
end
