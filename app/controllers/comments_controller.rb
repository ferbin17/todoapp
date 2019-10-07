class CommentsController < ApplicationController

  respond_to :html, :js

  def create
    @todo = Todo.find(params[:todo_id])
    @comment = @todo.comments.new(comment_params)
    @comment.save

    @comments = @todo.comments
    redirect_to @todo
  end

  private
    def comment_params
      params.require(:comment).permit(:body).merge("user_id" => current_user.id)
    end
end
