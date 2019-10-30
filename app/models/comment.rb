# frozen_string_literal: true

class Comment < ApplicationRecord
  validates_presence_of :body
  belongs_to :user
  belongs_to :todo

  scope :comment_join_user, ->(todo_id, comment_id) { joins(:user).select('users.*,comments.*').where('comments.todo_id = ? and comments.id=?', todo_id, comment_id) }

  # function to create comments
  def self.create_comment(params, current_user)
    todo = Todo.find_by(id: params[:todo_id])
    shares = todo.shares.select('user_id')
    unless shares.find_by(user_id: current_user.id).nil?
      comment = todo.comments.build(generate_comment(params).merge('user_id' => current_user.id))
      if comment.save
        comment = Comment.comment_join_user(todo.id, comment.id)[0]
        if params.key?(:new_value)
          todo.update(completion_status: params[:new_value])
          if todo.save
          else
            #show errors
          end
        end
      else
        #show errors
      end
    end
    comment
  end

  # function to construct comment body
  def self.generate_comment(params)
    if params.key?(:comment)
      body = { 'body' => "\"#{params[:comment]}\"" }
    else
      (params[:old_value]).gsub!((params[:old_value])[-1], '')
      unless params[:old_value] == params[:new_value]
        body = { body: 'Task has been updated from <span class="green-text">' + params[:old_value] + '%<span> to <span class="green-text">' + params[:new_value] + '%<span>' }
        body = { body: 'Status of the task changed to <span class="green-text">Done<span>' } if params[:new_value] == '100'
      end
    end
    body
  end
end
