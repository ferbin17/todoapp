class TodosController < ApplicationController

  respond_to :html, :js

  #index
  def index
    #calls mode function to return todos when params has either search or active status params
    if params.key?(:search) || params.key?(:active_status)
      todos = Todo.find_mode_and_return_todos(params, current_user)
      @todos = todos.paginate(:page => params[:page], per_page: 5)
      respond_to :js
    else
      # returns 5 active todos each with pagination at first loading
      todos = Todo.user_shared_partial_todos(true, current_user)
      @todos = todos.paginate(:page => params[:page], per_page: 5)
    end
  end

  #function for crating new todos, inserting corresponding entry in share table and update position value
  def create
    @todo = Todo.create_entry_in_todo(params, current_user)
    @todos = Todo.user_shared_partial_todos(true, current_user)
  end

  #function for deleteing todos and redirect to corresponding page with respect to the page from which the request came
  def destroy
    @todo = Todo.find_by(id: params[:id])
    @todo.destroy

    @todos = Todo.user_shared_partial_todos(@todo.active?, current_user)

    url = Rails.application.routes.recognize_path(request.referrer)
    if url[:action] == "show"
      render :js => "window.location = './../'"
    else
      respond_to :js
    end
  end

  #function to update active status of todo
  def update
    url = Rails.application.routes.recognize_path(request.referrer)
    @page = url[:action]

    @todo = Todo.find_by(id: params[:id])
    @todo.update(active: !@todo.active?)
    @todo.save

    @todos = Todo.user_shared_partial_todos(params[:active], current_user)
  end

  #funtion for rearranging todos
  def rearrange
    @todo = (Todo.todo_join_shares.user_shared_todos(current_user).where("todos.id = ?", params[:id]))[0]
    @direction = params[:direction]
    if params[:direction] == "down"
      Todo.move("down", @todo, current_user)
    else
      Todo.move("up", @todo, current_user)
    end
  end

  #funtion for showing each individual todo
  def show
    @todo = Todo.user_shared_todos(current_user).where(id: params[:id])[0]
    @shared = User.joins(:shares).select("users.*,shares.*").where("shares.todo_id = ? and shares.user_id != ?", @todo.id, @todo.user_id)

    @comments = User.joins(:comments).select('comments.*,users.*').where("comments.todo_id = ?", @todo.id)
  end

end
