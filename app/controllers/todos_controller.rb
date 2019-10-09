class TodosController < ApplicationController

  respond_to :html, :js

  #index
  def index
    if params.key?(:search)
      # Searching todo
      like_keyword = "%#{params[:search]}%"
      @todos = ( like_keyword == "%%" ? get_todos(true) : Todo.sort.search(like_keyword).logged_user(current_user))
      respond_to :js
    elsif params.key?(:active_status)
      # Show either all active todos or all inactive_only todos
      @todos = (params[:active_status] == "active_only" ? Todo.active_only : Todo.inactive_only)
      @todos = @todos.logged_user(current_user)
      respond_to :js
    else
      # Show all active todos at first loading
      @todos = get_todos(true)
      respond_to :html
    end
  end

  #function for crating new todos
  def create
    body = { "body" => params[:create] }
    @todo = Todo.new(body.merge("user_id" => current_user.id))
    if @todo.save
      Todo.update_position
    end

    @todos = get_todos(true)
  end

  #function for deleteing todos
  def destroy
    @todo = Todo.find(params[:id])
    active_status = @todo.active?
    @todo.destroy
    Todo.update_position
    @todos = get_todos(active_status)

    if params[:pg] == "index"
      respond_to :js
    else
      render :js => "window.location = './'"
    end
  end

  #function to update active status of todo
  def update
    @todo = Todo.find(params[:id])
    params[:active] == "true" ? @todo.update(active: false) : @todo.update(active: true)
    if @todo.save
      Todo.update_position
    end
    @todos = get_todos(params[:active])
  end

  #funtion for rearranging todos
  def rearrange
    if params[:direction] == "down"
      @todo = Todo.find(params[:id])
      @nexttodo = Todo.find_by(position: @todo.position-1)
      position = @nexttodo.position
      @nexttodo.update(position: @todo.position)
      @todo.update(position: position)
    else
      @todo = Todo.find(params[:id])
      @nexttodo = Todo.find_by(position: @todo.position+1)
      position = @nexttodo.position
      @nexttodo.update(position: @todo.position)
      @todo.update(position: position)
    end
    @todos = get_todos(params[:active_status])
  end

  #funtion for showing each individual todo
  def show
    @todo = Todo.find(params[:id])
    @comments = @todo.comments
  end

  #function for searching todo
  # def search
  #   like_keyword = "%#{params[:search].split("=").last}%";
  #   if like_keyword == "%%"
  #     @todos = get_todos(true)
  #   else
  #     @todos = Todo.sort.where("body LIKE ?", like_keyword).where(user_id: current_user.id)
  #   end
  # end

  # #funciton to show either all active todos or all inactive_only todos
  # def active_status
  #   @todos = (params[:active_status] == "active_only" ? Todo.active_only : Todo.inactive_only)
  #   @todos = @todos.where(user_id: current_user.id)
  # end

  private

  #funtion to fetch all todos of current user with respect to active status
  def get_todos(active_status)
    Todo.sort.where(active: active_status).logged_user(current_user)
  end

end
