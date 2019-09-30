class RemoveDatetimeTodo < ActiveRecord::Migration[6.0]
  def change
    remove_column :todos, :datetime
    add_column :todos, :active, :boolean, null:false, default: true
  end
end
