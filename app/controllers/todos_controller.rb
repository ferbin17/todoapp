# frozen_string_literal: true

class TodosController < ApplicationController
  respond_to :html, :js
  before_action :find_todo, only: %i[destroy update]

  helper FormattedTimeHelper

  # index
  def index
    # calls mode function to return todos when params has either search or active status params
    if params.key?(:search) || params.key?(:active_status)
      @todos = Todo.find_mode_and_return_todos(params, current_user).paginate(page: params[:page])
      respond_to :js
    else
      # returns 5 active todos each with pagination at first loading
      @todos = current_user.active_todos.paginate(page: params[:page])
    end
  end

  # function for crating new todos, inserting corresponding entry in share table and update position value
  def create
    @todo = Todo.create_entry_in_todo(params, current_user)
    @todos = current_user.todos.active_status_todos(true)
  end

  # function for deleteing todos and redirect to corresponding page with respect to the page from which the request came
  def destroy
    @todo.destroy
    @todos = current_user.todos.active_status_todos(@todo.active?)
    url = Rails.application.routes.recognize_path(request.referrer)
    if url[:action] == 'show'
      render js: "window.location = './../'"
    else
      respond_to :js
    end
  end

  # function to update active status of todo
  def update
    url = Rails.application.routes.recognize_path(request.referrer)
    @page = url[:action]
    @todo.update(active: !@todo.active?)
    @todos = current_user.todos.active_status_todos(!@todo.active?)
  end

  # funtion for rearranging todos
  def rearrange
    @todo = current_user.todos.select_shares_and_todo.where(id: params[:id])[0]
    @direction = params[:direction]
    if params[:direction] == 'down'
      Todo.check_move('down', @todo, current_user)
    else
      Todo.check_move('up', @todo, current_user)
    end
  end

  # funtion for showing each individual todo
  def show
    @todo = current_user.todos.select_shares_and_todo.where(id: params[:id])[0]
    @shared = User.get_shared_users(@todo)
    @comments = User.get_comments(@todo)
  end

  private

  def find_todo
    @todo = Todo.find_by(id: params[:id])
  end
end
