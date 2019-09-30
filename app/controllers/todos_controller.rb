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
    else
      @@status[:value] = Todo.sort
      @todos = @@status[:value].where(active: true, user_id: current_user.id)
    end
  end

  def create
    @todo = Todo.new(parse_params.merge("user_id" => current_user.id))
    if @todo.save
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy
    redirect_to root_path
  end

  def search
    @@status[:function] = "search"
    like_keyword = "%#{params.require(:todo).permit(:search)[:search]}%"
    if like_keyword == "%%"
      @@status[:value] = @@status[:value].where("body LIKE ?", like_keyword).where(active: true)
    else
      @@status[:value] = @@status[:value].where("body LIKE ?", like_keyword)
    end
    redirect_to root_path
  end

  def update
    @todo = Todo.find(params[:id])
    params[:active] == "true" ? @todo.update(active: false) : @todo.update(active: true)
    if @todo.save
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def active_status
    @@status[:function] = "active_status"
    @@status[:value] = (params[:active_status] == "active_only" ? Todo.where(active: true).order(id: :desc) : Todo.where(active: false).order(id: :desc))
    redirect_to root_path
  end

  def rearrange
    p params
    # p @todo = Todo.find(params[:id])
  end

  private
  def parse_params
    params.require(:todo).permit(:body)
  end
end
