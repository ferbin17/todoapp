class TodosController < ApplicationController

  respond_to :html, :js

  #index
  def index
    if params.key?(:search)
      # Searching todo
      like_keyword = "%#{params[:search]}%"
      @todos = ( like_keyword == "%%" ? get_todos(true) : get_todos("").
          search(like_keyword))
      @todos = @todos.paginate(:page => params[:page], per_page: 5)
      respond_to :js

    elsif params.key?(:active_status)
      # Show either all active todos or all inactive_only todos
      @todos = (params[:active_status] == "active_only" ? get_todos(true) : get_todos(false))
      @todos = @todos.paginate(:page => params[:page], per_page: 5)
      respond_to :js
    else
      # Show all active todos at first loading
      @todos = get_todos(true)
      @todos = @todos.paginate(:page => params[:page], per_page: 5)
    end
  end

  #function for crating new todos
  def create
    # TODO: change to call backs
    body = { "body" => params[:create] }
    @todo = Todo.new(body.merge("user_id" => current_user.id))
    if @todo.save
      @share = Share.new("user_id" => current_user.id, "todo_id" => @todo.id, is_owner: true)
      if @share.save
        @user = User.find(current_user.id)
        top_todo = (@user.shares.order(:position)).last
        if top_todo == nil
          @share.update(position: 1)
        else
          @share.update(position: top_todo.position+1)
        end
      end
      @todo = get_todos(true).where(id: @todo.id)[0]
    end

    @todos = get_todos(true)
  end

  #function for deleteing todos
  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy

    @todos = get_todos(@todo.active?)

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
    @todo = Todo.find(params[:id])
    params[:active] == "true" ? @todo.update(active: false) : @todo.
        update(active: true)

    @todo.save

    @todos = get_todos(params[:active])
  end

  #funtion for rearranging todos
  def rearrange
    @todo = (Todo.joins(:shares).select("shares.*,todos.*").where("shares.user_id= ? and todos.id = ?", current_user.id, params[:id]))[0]
    @direction = params[:direction]
    if params[:direction] == "down"
      Todo.move("down", @todo, current_user)
    else
      Todo.move("up", @todo, current_user)
    end
  end

  #funtion for showing each individual todo
  def show
    @todo = get_todos("").where(id: params[:id])[0]
    @shared = Share.where("todo_id = ? and user_id != ?", @todo.id, @todo.user_id) # TODO: current_user id or owner id
    @comments = @todo.comments
  end

  private

  #funtion to fetch all todos of current user with respect to active status
  def get_todos(active_status)
    return Todo.joins(:shares).select("shares.*,todos.*").where("shares.user_id= ?", current_user.id).order(position: :desc) if active_status == ""
    return Todo.joins(:shares).select("shares.*,todos.*").where("todos.active=? and shares.user_id= ?", active_status, current_user.id).order(position: :desc)
  end

end
