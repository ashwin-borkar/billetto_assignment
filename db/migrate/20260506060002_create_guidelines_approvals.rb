class CreateGuidelinesApprovals < ActiveRecord::Migration[7.0]
  def change
    create_table :guidelines_approvals do |t|
      t.references :request_for_comment, null: false, foreign_key: { to_table: :guidelines_request_for_comments }
      t.string :developer_id, null: false
      t.timestamps

      t.index [:request_for_comment_id, :developer_id], unique: true, name: 'index_guidelines_approvals_on_rfc_and_dev'
    end
  end
end
