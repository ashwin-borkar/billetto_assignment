class CreateGuidelinesRequestForComments < ActiveRecord::Migration[7.0]
  def change
    create_table :guidelines_request_for_comments do |t|
      t.string :tid, null: false, index: { unique: true }
      t.string :number, null: false
      t.text :description, null: false
      t.string :author_id, null: false
      t.timestamps
    end
  end
end
