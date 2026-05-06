class RequestForCommentApprovalsController < ApiController
  def create
    command_bus.call(
      Guidelines::ApproveByDeveloper.new(
        tid: params[:id],
        developer_id: params[:developer_id]
      )
    )
    
    head :created
  end
end
