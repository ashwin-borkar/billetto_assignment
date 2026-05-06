require 'rails_helper'

RSpec.describe Billetto::Client do
  let(:api_key) { 'test-api-key' }
  let(:client) { Billetto::Client.new(api_key) }
  let(:events_response) do
    {
      'data' => [
        {
          'id' => 'event-1',
          'title' => 'Test Event 1',
          'description' => 'Test Description 1',
          'start_time' => '2026-06-01T19:00:00Z',
          'end_time' => '2026-06-01T22:00:00Z',
          'image_url' => 'https://example.com/image1.jpg',
          'price' => 25.50,
          'venue' => {
            'name' => 'Test Venue 1',
            'city' => 'Test City 1',
            'country' => 'Test Country 1'
          }
        }
      ]
    }
  end

  describe '#fetch_events' do
    context 'when API call is successful' do
      before do
        stub_request(:get, 'https://api.billetto.com/v1/events/public')
          .with(
            headers: {
              'Authorization' => "Bearer #{api_key}",
              'Content-Type' => 'application/json'
            }
          )
          .to_return(
            status: 200,
            body: events_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns parsed response' do
        result = client.fetch_events
        expect(result).to eq(events_response)
      end
    end

    context 'when API call fails' do
      before do
        stub_request(:get, 'https://api.billetto.com/v1/events/public')
          .with(
            headers: {
              'Authorization' => "Bearer #{api_key}",
              'Content-Type' => 'application/json'
            }
          )
          .to_return(
            status: 401,
            body: { 'error' => 'Unauthorized' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'raises ApiError' do
        expect {
          client.fetch_events
        }.to raise_error(Billetto::ApiError, /Failed to fetch events: 401/)
      end
    end
  end

  describe '#fetch_event' do
    let(:event_id) { 'event-1' }
    let(:event_response) { events_response['data'].first }

    context 'when API call is successful' do
      before do
        stub_request(:get, "https://api.billetto.com/v1/events/#{event_id}")
          .with(
            headers: {
              'Authorization' => "Bearer #{api_key}",
              'Content-Type' => 'application/json'
            }
          )
          .to_return(
            status: 200,
            body: event_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns parsed response' do
        result = client.fetch_event(event_id)
        expect(result).to eq(event_response)
      end
    end

    context 'when API call fails' do
      before do
        stub_request(:get, "https://api.billetto.com/v1/events/#{event_id}")
          .with(
            headers: {
              'Authorization' => "Bearer #{api_key}",
              'Content-Type' => 'application/json'
            }
          )
          .to_return(
            status: 404,
            body: { 'error' => 'Not Found' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'raises ApiError' do
        expect {
          client.fetch_event(event_id)
        }.to raise_error(Billetto::ApiError, /Failed to fetch event: 404/)
      end
    end
  end
end
