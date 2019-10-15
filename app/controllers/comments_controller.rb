class CommentsController < ApplicationController

  respond_to :html, :js

  def create
    p params
    @todo = Todo.find(params[:todo_id])
    @comment = @todo.comments.new(comment_params.merge("user_id" => current_user.id))
    if @comment.save
      if params.key?(:new_value)
        @todo.update(completion_status: params[:new_value]);
        @todo.save
      end
    end

    @comments = @todo.comments
  end

  private
    def comment_params
      { "body" => params[:comment] }
    end
end
