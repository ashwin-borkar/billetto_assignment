class MakeValidAtNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :event_store_events, :valid_at, true
  end
end
