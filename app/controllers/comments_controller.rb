class CommentsController < ApplicationController

  respond_to :html, :js

  def create
    @todo = Todo.find(params[:todo_id])
    @shares = User.joins(:shares).select("users.id").where("shares.todo_id=? AND shares.is_owner=false", params[:todo_id])
    @shares.each do |share|
      if share.id == current_user.id
        if params.key?(:comment)
          comment = { "body" => "\"#{params[:comment]}\"" }
        else
          (params[:old_value]).gsub!((params[:old_value])[-1],"")
          if params[:new_value] == "100"
            comment = { body: "Status of the task changed to <span class=\"green-text\">Done<span>" }
          else
            unless params[:old_value] == params[:new_value]
              comment = { body: "Task has been updated from <span class=\"green-text\">" + params[:old_value] + "%<span> to <span class=\"green-text\">" + params[:new_value] + "%<span>" }
            end
          end
        end
          @comment = @todo.comments.new(comment.merge("user_id" => current_user.id))
        if @comment.save
          if params.key?(:new_value)
            @todo.update(completion_status: params[:new_value]);
            @todo.save
          end
        end
      end
    end

    @comments = @todo.comments
  end

end
