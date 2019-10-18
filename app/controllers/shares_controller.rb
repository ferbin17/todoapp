class SharesController < ApplicationController

  respond_to :html, :js

  def index
    @todo = Todo.find(params[:id])
    @users =  User.all.where("id != ?", @todo.user_id)
    @shares = User.joins(:shares).select("users.id").where("shares.todo_id=? AND shares.is_owner=false", params[:id]).order(:id)
    respond_to :js
  end

  def create
    @shares = User.joins(:shares).select("users.id").where("shares.todo_id=? AND shares.is_owner=false", params[:id]).order(:id)
    @users = params[:users]
    @users.each do |user|
      if @shares.find_by(id: user) == nil
        Share.create(user_id: user, todo_id: params[:id])
      end
    end
    @shares.each do |share|
      unless @users.include? ("#{share.id}")
       (Share.find_by(user_id: share.id, todo_id: params[:id])).destroy
      end
    end
    @shares = User.joins(:shares).select("users.id").where("shares.todo_id=? AND shares.is_owner=false", params[:id]).order(:id)
  end

  def get_todos(active_status)
    return Todo.joins(:shares).select("shares.*,todos.*").where("shares.user_id= ?", current_user.id).order(position: :desc) if active_status == ""
    return Todo.joins(:shares).select("shares.*,todos.*").where("todos.active=? and shares.user_id= ?", active_status, current_user.id).order(position: :desc)
  end
end
