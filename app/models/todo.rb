class Todo < ApplicationRecord
  validates_presence_of :body
  belongs_to :user

  def self.sort
    @todos = Todo.all
    return @todos.order(position: :desc)
  end

  def self.active_only
    Todo.where(active: true).order(position: :desc)
  end

  def self.inactive_only
    Todo.where(active: false).order(position: :desc)
  end

  def self.update_position
    Todo.where(active: true).order(:updated_at).each.with_index(1) do |todo, index|
      todo.update_column :position, index
    end

    Todo.where(active: false).order(:updated_at).each.with_index(10000) do |todo, index|
      todo.update_column :position, index
    end
  end

end
