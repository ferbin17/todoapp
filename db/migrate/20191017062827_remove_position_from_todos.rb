class RemovePositionFromTodos < ActiveRecord::Migration[6.0]
  def change
    remove_column :todos, :position
  end
end
