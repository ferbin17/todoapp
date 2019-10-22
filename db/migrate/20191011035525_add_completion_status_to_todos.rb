class AddCompletionStatusToTodos < ActiveRecord::Migration[6.0]
  def change
    add_column :todos, :completion_status, :bigint, default: 0, null: false
  end
end
