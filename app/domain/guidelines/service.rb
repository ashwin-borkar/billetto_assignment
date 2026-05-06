module Guidelines
  class Service
    include Command::Handler
    
    handles IssueRequestForComment, :issue_rfc
    handles ApproveRequestForComment, :approve_rfc

    def initialize(rfc_number_generator = RfcNumberGenerator.new)
      @rfc_number_generator = rfc_number_generator
    end

    private

    attr_reader :rfc_number_generator

    def issue_rfc(cmd)
      rfc = RequestForComment.create!(
        number: rfc_number_generator.call,
        description: cmd.description,
        author_id: cmd.developer_id,
      )
      
      event_store.publish(RfcIssued.new(data: {
        tid: rfc.tid,
        developer_id: rfc.developer_id,
        number: rfc.number,
      }))
    end

    def approve_rfc(cmd)
      rfc = ObjectRepository.find(cmd.tid)
      rfc.approve!
    end
  end
end
