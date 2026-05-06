module Guidelines
  class Approval < ApplicationRecord
    belongs_to :request_for_comment, class_name: 'Guidelines::RequestForComment'
    has_one :developer
    
    self.table_name = 'guidelines_approvals'
    
    validates :developer_id, presence: true
    validates :request_for_comment_id, presence: true
    validates :developer_id, uniqueness: { scope: :request_for_comment_id }
  end
end
