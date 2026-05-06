require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      event = build(:event)
      expect(event).to be_valid
    end

    it 'is invalid without a title' do
      event = build(:event, title: nil)
      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without an external_id' do
      event = build(:event, external_id: nil)
      expect(event).not_to be_valid
      expect(event.errors[:external_id]).to include("can't be blank")
    end

    it 'is invalid with duplicate external_id' do
      create(:event, external_id: 'test-123')
      event = build(:event, external_id: 'test-123')
      expect(event).not_to be_valid
      expect(event.errors[:external_id]).to include("has already been taken")
    end
  end

  describe 'scopes and methods' do
    let!(:upcoming_event) { create(:event, start_date: 1.day.from_now) }
    let!(:past_event) { create(:event, start_date: 1.day.ago) }

    describe '.upcoming' do
      it 'returns events that are in the future' do
        expect(Event.upcoming).to include(upcoming_event)
        expect(Event.upcoming).not_to include(past_event)
      end
    end

    describe '.past' do
      it 'returns events that have already occurred' do
        expect(Event.past).to include(past_event)
        expect(Event.past).not_to include(upcoming_event)
      end
    end

    describe '#upcoming?' do
      it 'returns true for future events' do
        expect(upcoming_event.upcoming?).to be true
      end

      it 'returns false for past events' do
        expect(past_event.upcoming?).to be false
      end
    end

    describe '#past?' do
      it 'returns true for past events' do
        expect(past_event.past?).to be true
      end

      it 'returns false for future events' do
        expect(upcoming_event.past?).to be false
      end
    end

    describe '#total_votes' do
      it 'returns the sum of upvotes and downvotes' do
        event = create(:event, upvotes_count: 10, downvotes_count: 5)
        expect(event.total_votes).to eq(15)
      end
    end
  end

  describe '.from_billetto_data' do
    let(:billetto_data) do
      {
        id: 'billetto-123',
        title: 'Test Event',
        description: 'Test Description',
        start_time: 1.day.from_now,
        end_time: 1.day.from_now + 2.hours,
        image_url: 'https://example.com/image.jpg',
        price: 25.50,
        venue: {
          name: 'Test Venue',
          city: 'Test City',
          country: 'Test Country'
        }
      }
    end

    context 'when event does not exist' do
      it 'creates a new event with correct attributes' do
        event = Event.from_billetto_data(billetto_data)
        
        expect(event).to be_new_record
        expect(event.external_id).to eq('billetto-123')
        expect(event.title).to eq('Test Event')
        expect(event.description).to eq('Test Description')
        expect(event.start_date.to_i).to eq(billetto_data[:start_time].to_i)
        expect(event.end_date).to eq(billetto_data[:end_time])
        expect(event.image_url).to eq('https://example.com/image.jpg')
        expect(event.price).to eq(25.50)
        expect(event.location).to eq('Test Venue, Test City')
      end
    end

    context 'when event already exists' do
      let!(:existing_event) { create(:event, external_id: 'billetto-123', title: 'Old Title') }

      it 'finds the existing event' do
        event = Event.from_billetto_data(billetto_data)
        expect(event).to eq(existing_event)
      end

      it 'updates the event attributes' do
        event = Event.from_billetto_data(billetto_data)
        event.save
        
        expect(event.title).to eq('Test Event')
        expect(event.description).to eq('Test Description')
      end
    end
  end
end
