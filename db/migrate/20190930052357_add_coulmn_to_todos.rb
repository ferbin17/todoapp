class AddCoulmnToTodos < ActiveRecord::Migration[6.0]
  def change
    add_column :todos, :priority, :int
  end
end
