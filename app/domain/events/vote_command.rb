module Events
  class VoteCommand
    include ActiveModel::Model
    include ActiveModel::Attributes
    
    attribute :event_id, :string
    attribute :user_id, :string
    attribute :vote_type, :string
    
    validates :event_id, :user_id, :vote_type, presence: true
    validates :vote_type, inclusion: { in: %w[upvote downvote] }
    
    def call
      return false unless valid?
      
      event = Event.find_by(external_id: event_id)
      return false unless event

      event_store = RailsEventStore::Client.new   # ✅ use this only
      
      case vote_type
      when 'upvote'
        event_store.publish(
          Events::EventUpvoted.new(
            data: {
              event_id: event_id,
              user_id: user_id
            }
          )
        )
        event.increment!(:upvotes_count)

      when 'downvote'
        event_store.publish(
          Events::EventDownvoted.new(
            data: {
              event_id: event_id,
              user_id: user_id
            }
          )
        )
        event.increment!(:downvotes_count)
      end
      
      true
    end
  end
end