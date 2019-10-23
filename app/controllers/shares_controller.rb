class SharesController < ApplicationController

  respond_to :html, :js

  #shows all the users with check for shared users on share button click
  def index
    @todo = Todo.find_by(id: params[:id])
    @users =  User.all.where("id != ?", @todo.user_id)
    @shares = Share.select_iser_id.shared_users(params[:id])
    respond_to :js
  end

  #add or remove new users as shared users for a particular todo
  def create
    @shares = Share.select_iser_id.shared_users(params[:id])
    @users = params[:users]
    @users.each do |user|
      break if user == "0"
      if @shares.find_by(user_id: user) == nil
        @user = User.find_by(id: user)
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
    @shares = User.joins(:shares).select('users.*,shares.*').shared_users(params[:id])
  end

end
