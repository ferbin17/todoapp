class Todo < ApplicationRecord
  has_one :user
  validates_presence_of :body

  def self.sort
    @todos = Todo.all
    return @todos.order(position: :desc)
  end

  def self.update_position
    Todo.order(:updated_at).each.with_index(1) do |todo, index|
      todo.update_column :position, index
    end
  end
end
