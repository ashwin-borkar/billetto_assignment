module ReadModels
  class NumberOfRfcIssuedByDeveloper
    include Handler.async(queue: "low")
    subscribes_to Guidelines::RfcIssued

    class Count < ApplicationRecord
      self.table_name = "number_of_rfc_issued_by_developer"
      
      validates :developer_id, presence: true
      validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }
    end

    def call(fact)
      developer_id = fact.data.fetch(:developer_id)
      
      ApplicationRecord.transaction do
        Count.find_or_initialize_by(developer_id: developer_id).lock!.tap do |record|
          record.value = (record.value || 0) + 1
          record.save!
        end
      end
    end
  end
end
