class SharesController < ApplicationController

  respond_to :html, :js

  #shows all the users with check for shared users on share button click
  def index
    @users =  User.all.all_user_except_one(current_user)
    @shares = Share.select_user_id.shared_users(params[:id])
    respond_to :js
  end

  #add or remove new users as shared users for a particular todo
  def create
    Share.manage_share(params)
    @shares = User.userjoinshares(params[:id])
  end

end
