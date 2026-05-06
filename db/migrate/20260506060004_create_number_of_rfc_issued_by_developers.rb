class CreateNumberOfRfcIssuedByDevelopers < ActiveRecord::Migration[7.0]
  def change
    create_table :number_of_rfc_issued_by_developers do |t|
      t.string :developer_id, null: false, index: { unique: true }
      t.integer :value, null: false, default: 0
      t.timestamps
    end
  end
end
