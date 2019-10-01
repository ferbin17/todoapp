class TodosController < ApplicationController

  @@status = { :function => "", :value => "" }

  def self.status
    @@status
  end

  def index
    case @@status[:function]
    when "search"
      @todos = @@status[:value].where(user_id: current_user.id)
      @@status[:function] = ""
    when "active_status"
      @todos = @@status[:value].where(user_id: current_user.id)
      @@status[:function] = ""
    when "rearrange"
      @todos = @@status[:value].where(user_id: current_user.id)
      @@status[:function] = ""
    when "update"
      @todos = @@status[:value].where(user_id: current_user.id)
      @@status[:function] = ""
    else
      @@status[:value] = Todo.sort
      @todos = @@status[:value].where(active: true, user_id: current_user.id)
    end
  end

  def create
    @todo = Todo.new(parse_params.merge("user_id" => current_user.id))
    if @todo.save
      Todo.update_position
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy
    Todo.update_position
    redirect_to root_path
  end

  def search
    @@status[:function] = "search"
    like_keyword = "%#{params.require(:todo).permit(:search)[:search]}%"
    if like_keyword == "%%"
      @@status[:value] = Todo.sort.where("body LIKE ?", like_keyword).where(active: true)
    else
      @@status[:value] = Todo.sort.where("body LIKE ?", like_keyword)
    end
    redirect_to root_path
  end

  def update
    @@status[:function] = "update"
    @todo = Todo.find(params[:id])
    params[:active] == "true" ? @todo.update(active: false) : @todo.update(active: true)
    if @todo.save
      Todo.update_position
      @@status[:value] =  @@status[:value].where(active: params[:active])
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def active_status
    @@status[:function] = "active_status"
    @@status[:value] = (params[:active_status] == "active_only" ? Todo.active_only : Todo.inactive_only)
    redirect_to root_path
  end

  def rearrange
    @@status[:function] = "rearrange"
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
    @@status[:value] = @@status[:value].where(active: params[:active_status])
    redirect_to root_path
  end

  def show
    @todo = Todo.find(params[:id])
  end

  private
  def parse_params
    params.require(:todo).permit(:body)
  end
end
