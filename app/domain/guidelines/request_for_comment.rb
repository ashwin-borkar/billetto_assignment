module Guidelines
  class RequestForComment < ApplicationRecord
    include EventStoreInjector
    include HasTypeid
    has_typeid :rfc
    has_many :approvals, dependent: :destroy
    
    self.table_name = 'guidelines_request_for_comments'

    def approve_by!(developer_id)
      approvals.create!(developer_id: developer_id)
      event_store.publish(
        RfcApprovedByDeveloper.new(
          data: {
            tid: tid,
            developer_id: developer_id
          }
        )
      )
    end

    def approve!
      event_store.publish(
        RfcApproved.new(data: { tid: tid })
      )
    end
  end
end
