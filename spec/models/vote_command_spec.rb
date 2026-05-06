require 'rails_helper'

RSpec.describe Events::VoteCommand, type: :model do
  let(:event) { create(:event) }
  let(:user_id) { SecureRandom.uuid }

  describe 'validations' do
    it 'is valid with all required attributes' do
      command = Events::VoteCommand.new(
        event_id: event.external_id,
        user_id: user_id,
        vote_type: 'upvote'
      )
      expect(command).to be_valid
    end

    it 'is invalid without event_id' do
      command = Events::VoteCommand.new(
        user_id: user_id,
        vote_type: 'upvote'
      )
      expect(command).not_to be_valid
      expect(command.errors[:event_id]).to include("can't be blank")
    end

    it 'is invalid without user_id' do
      command = Events::VoteCommand.new(
        event_id: event.external_id,
        vote_type: 'upvote'
      )
      expect(command).not_to be_valid
      expect(command.errors[:user_id]).to include("can't be blank")
    end

    it 'is invalid without vote_type' do
      command = Events::VoteCommand.new(
        event_id: event.external_id,
        user_id: user_id
      )
      expect(command).not_to be_valid
      expect(command.errors[:vote_type]).to include("can't be blank")
    end

    it 'is invalid with invalid vote_type' do
      command = Events::VoteCommand.new(
        event_id: event.external_id,
        user_id: user_id,
        vote_type: 'invalid'
      )
      expect(command).not_to be_valid
      expect(command.errors[:vote_type]).to include("is not included in the list")
    end
  end

  describe '#call' do
    context 'with valid upvote' do
      let(:command) do
        Events::VoteCommand.new(
          event_id: event.external_id,
          user_id: user_id,
          vote_type: 'upvote'
        )
      end

      it 'increments upvotes count' do
        expect {
          expect(command.call).to be true
        }.to change { event.reload.upvotes_count }.by(1)
      end

      it 'publishes EventUpvoted event' do
        expect(Rails.configuration.event_store).to receive(:publish).with(
          have_attributes(
            class: Events::EventUpvoted,
            data: {
              event_id: event.external_id,
              user_id: user_id
            }
          )
        )
        
        command.call
      end
    end

    context 'with valid downvote' do
      let(:command) do
        Events::VoteCommand.new(
          event_id: event.external_id,
          user_id: user_id,
          vote_type: 'downvote'
        )
      end

      it 'increments downvotes count' do
        expect {
          expect(command.call).to be true
        }.to change { event.reload.downvotes_count }.by(1)
      end

      it 'publishes EventDownvoted event' do
        expect(Rails.configuration.event_store).to receive(:publish).with(
          have_attributes(
            class: Events::EventDownvoted,
            data: {
              event_id: event.external_id,
              user_id: user_id
            }
          )
        )
        
        command.call
      end
    end

    context 'with non-existent event' do
      let(:command) do
        Events::VoteCommand.new(
          event_id: 'non-existent-id',
          user_id: user_id,
          vote_type: 'upvote'
        )
      end

      it 'returns false' do
        expect(command.call).to be false
      end
    end

    context 'with invalid command' do
      let(:command) do
        Events::VoteCommand.new(
          event_id: event.external_id,
          user_id: user_id,
          vote_type: 'invalid'
        )
      end

      it 'returns false' do
        expect(command.call).to be false
      end
    end
  end
end
