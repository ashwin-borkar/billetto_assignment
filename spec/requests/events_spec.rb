require 'rails_helper'

RSpec.describe "Events", type: :request do
  let!(:event) { create(:event) }

  describe "GET /events" do
    it "returns a successful response" do
      get events_path
      expect(response).to be_successful
      expect(response.body).to include(event.title)
    end

    it "filters upcoming events" do
      upcoming_event = create(:event, start_date: 1.day.from_now)
      past_event = create(:event, start_date: 1.day.ago)

      get events_path(filter: "upcoming")
      expect(response.body).to include(upcoming_event.title)
      expect(response.body).not_to include(past_event.title)
    end

    it "filters past events" do
      upcoming_event = create(:event, start_date: 1.day.from_now)
      past_event = create(:event, start_date: 1.day.ago)

      get events_path(filter: "past")
      expect(response.body).to include(past_event.title)
      expect(response.body).not_to include(upcoming_event.title)
    end
  end

  describe "GET /events/:id" do
    it "returns a successful response" do
      get event_path(event)
      expect(response).to be_successful
      expect(response.body).to include(event.title)
      expect(response.body).to include(event.description)
    end
  end

  describe "POST /events/:id/upvote" do
    it "increments upvotes count" do
      expect {
        post upvote_event_path(event)
      }.to change { event.reload.upvotes_count }.by(1)
      
      expect(response).to redirect_to(event_path(event))
      expect(flash[:notice]).to eq("Event upvoted successfully!")
    end

    it "creates an EventUpvoted event in the event store" do
      expect(Rails.configuration.event_store).to receive(:publish).with(
        have_attributes(class: Events::EventUpvoted)
      )
      
      post upvote_event_path(event)
    end
  end

  describe "POST /events/:id/downvote" do
    it "increments downvotes count" do
      expect {
        post downvote_event_path(event)
      }.to change { event.reload.downvotes_count }.by(1)
      
      expect(response).to redirect_to(event_path(event))
      expect(flash[:notice]).to eq("Event downvoted successfully!")
    end

    it "creates an EventDownvoted event in the event store" do
      expect(Rails.configuration.event_store).to receive(:publish).with(
        have_attributes(class: Events::EventDownvoted)
      )
      
      post downvote_event_path(event)
    end
  end
end
