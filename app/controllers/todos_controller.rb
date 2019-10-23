class TodosController < ApplicationController

  respond_to :html, :js

  #index
  def index
    if params.key?(:search)
      # Searching todo, returns all active todos if keyword is not present else returns the search results
      like_keyword = "%#{params[:search]}%"
      @todos = ( like_keyword == "%%" ? Todo.user_shared_partial_todos(true, current_user) : Todo.
          user_shared_todos(current_user).search(like_keyword))
      @todos = @todos.paginate(:page => params[:page], per_page: 5)
      respond_to :js

    elsif params.key?(:active_status)
      # returns either all active todos or all inactive_only todos
      @todos = (params[:active_status] == "active_only" ?
        Todo.user_shared_partial_todos(true, current_user) :
        Todo.user_shared_partial_todos(false, current_user))
      @todos = @todos.paginate(:page => params[:page], per_page: 5)
      respond_to :js
    else
      # returns 5 active todos each with pagination at first loading
      @todos = Todo.user_shared_partial_todos(true, current_user)
      @todos = @todos.paginate(:page => params[:page], per_page: 5)
    end
  end

  #function for crating new todos, inserting corresponding entry in share table and update position value
  def create
    body = { "body" => params[:create] }
    @todo = Todo.new(body.merge("user_id" => current_user.id))
    if @todo.save
      @share = Share.new("user_id" => current_user.id, "todo_id" => @todo.id, is_owner: true)
      if @share.save
        @user = User.find_by(id: current_user.id)
        top_todo = (@user.shares.order(:position)).last
        if top_todo == nil
          @share.update(position: 1)
        else
          @share.update(position: top_todo.position+1)
        end
      end
      @todo = Todo.user_shared_partial_todos(true, current_user).where(id: @todo.id)[0]
    end

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
