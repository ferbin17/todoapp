class TodosController < ApplicationController

  respond_to :html, :js

  #index
  def index
    if params.key?(:search)
      # Searching todo
      like_keyword = "%#{params[:search]}%"
      @todos = ( like_keyword == "%%" ? get_todos(true) : Todo.sort.
          search(like_keyword).logged_user(current_user))
      respond_to :js

    elsif params.key?(:active_status)
      # Show either all active todos or all inactive_only todos
      @todos = (params[:active_status] == "active_only" ? Todo.
          active_only : Todo.inactive_only)
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
    @todo.save

    @todos = get_todos(true)
  end

  #function for deleteing todos
  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy

    @todos = get_todos(@todo.active?)

    if params[:pg] == "index"
      respond_to :js
    else
      render :js => "window.location = './'"
    end
  end

  #function to update active status of todo
  def update
    @todo = Todo.find(params[:id])
    params[:active] == "true" ? @todo.update(active: false) : @todo.
        update(active: true)
    @todo.save

    @todos = get_todos(params[:active])
  end

  #funtion for rearranging todos
  def rearrange
    @todo = Todo.find(params[:id])
    @direction = params[:direction]
    if params[:direction] == "down"
      Todo.move("down",params[:id])
    else
      Todo.move("up",params[:id])
    end
  end

  #funtion for showing each individual todo
  def show
    @todo = Todo.find(params[:id])
    @comments = @todo.comments
  end

  private

  #funtion to fetch all todos of current user with respect to active status
  def get_todos(active_status)
    Todo.sort.where(active: active_status).logged_user(current_user)
  end

end
