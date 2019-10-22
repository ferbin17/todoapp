class SharesController < ApplicationController

  respond_to :html, :js

  def index
    @todo = Todo.find(params[:id])
    @users =  User.all.where("id != ?", @todo.user_id)
    @shares = Share.select('user_id').where("todo_id=? AND is_owner=false", params[:id]).order(:user_id)
    respond_to :js
  end

  def create
    @shares = Share.select('user_id').where("todo_id=? AND is_owner=false", params[:id]).order(:user_id)
    @users = params[:users]
    @users.each do |user|
      break if user == "0"
      if @shares.find_by(user_id: user) == nil
        @user = User.find(user)
        top_todo = (@user.shares.order(:position)).last
        if top_todo == nil
          Share.create(user_id: user, todo_id: params[:id], position: 1)
        else
          Share.create(user_id: user, todo_id: params[:id], position: top_todo.position+1)
        end
      end
    end
    @shares.each do |share|
      unless @users.include? ("#{share.user_id}")
       (Share.find_by(user_id: share.user_id, todo_id: params[:id])).destroy
      end
    end
    @shares = User.joins(:shares).select('users.*,shares.*').where("todo_id=? AND is_owner=false", params[:id]).order(:user_id)
  end

end
