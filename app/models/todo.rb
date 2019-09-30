class Todo < ApplicationRecord
  has_one :user
  validates_presence_of :body

  def self.sort
    @todos = Todo.all
    return @todos.order(id: :desc)
  end
end
