class AddPositionToTodos < ActiveRecord::Migration[6.0]
  def change
    add_column :todos, :position, :integer
  end
end
