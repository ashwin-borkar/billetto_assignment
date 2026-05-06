module Guidelines
  class ApproveByDeveloper < Command::Base
    include Command::Executable
    
    attribute :tid, String
    attribute :developer_id, String
    
    validates :tid, :developer_id, presence: true

    def call
      rfc = ObjectRepository.find(tid)
      raise ActiveRecord::RecordNotFound, "RFC not found: #{tid}" unless rfc
      
      rfc.approve_by!(developer_id)
    rescue ActiveRecord::RecordInvalid => e
      raise Command::ValidationError, "Failed to approve RFC: #{e.message}"
    end
  end

  class ValidationError < StandardError; end
end
