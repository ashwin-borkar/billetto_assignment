class Event < ApplicationRecord
  validates :title, presence: true
  validates :external_id, presence: true, uniqueness: true
  
  scope :upcoming, -> { where('start_date > ?', Time.current) }
  scope :past, -> { where('start_date <= ?', Time.current) }
  
  def self.from_billetto_data(data)
    find_or_initialize_by(external_id: data[:id]).tap do |event|
      event.assign_attributes(
        title: data[:title],
        description: data[:description],
        start_date: data[:start_time],
        end_date: data[:end_time],
        image_url: data[:image_url],
        location: "#{data.dig(:venue, :name)}, #{data.dig(:venue, :city)}",
        price: data[:price] || 0.0
      )
    end
  end
  
  def upcoming?
    start_date && start_date > Time.current
  end
  
  def past?
    start_date && start_date <= Time.current
  end
  
  def total_votes
    upvotes_count + downvotes_count
  end
end
