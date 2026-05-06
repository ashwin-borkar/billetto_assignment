class EventsController < ApplicationController
  before_action :set_event, only: [:show, :upvote, :downvote]
  
  def index
    @events = Event.order(start_date: :asc).page(params[:page]).per(12)
    
    if params[:filter] == 'upcoming'
      @events = @events.upcoming
    elsif params[:filter] == 'past'
      @events = @events.past
    end
  end
  
  def show
    @event_votes = @event.total_votes
  end
  
  def upvote
    command = Events::VoteCommand.new(
      event_id: @event.external_id,
      user_id: current_user_id,
      vote_type: 'upvote'
    )
    
    if command.call
      redirect_to @event, notice: 'Event upvoted successfully!'
    else
      redirect_to @event, alert: 'Failed to upvote event'
    end
  end
  
  def downvote
    command = Events::VoteCommand.new(
      event_id: @event.external_id,
      user_id: current_user_id,
      vote_type: 'downvote'
    )
    
    if command.call
      redirect_to @event, notice: 'Event downvoted successfully!'
    else
      redirect_to @event, alert: 'Failed to downvote event'
    end
  end
  
  private
  
  def set_event
    @event = Event.find(params[:id])
  end
  
  def current_user_id
    # TODO: Implement proper user authentication with Clerk
    # For now, using session-based user ID
    session[:user_id] ||= SecureRandom.uuid
  end
end
