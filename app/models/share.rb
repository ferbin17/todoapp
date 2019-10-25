# frozen_string_literal: true

class Share < ApplicationRecord
  has_many :todos
  belongs_to :user
  belongs_to :todo

  scope :shared_users, ->(id) { where('todo_id=? AND is_owner=false', id).order(:user_id) }
  scope :select_user_id, -> { select('user_id') }
  scope :create_share_entry, ->(user_id, todo_id, position) { create(user_id: user_id, todo_id: todo_id, position: position) }

  # function to manage share entries
  def self.manage_share(params)
    shared = Share.select_user_id.shared_users(params[:id])
    create_entry_to_share(shared, params)
    remove_entry_from_share(shared, params)
  end

  # function to make new share entry
  def self.create_entry_to_share(shared, params)
    users = params[:users]
    users.each do |user_id|
      break if user_id == '0'

      next unless shared.find_by(user_id: user_id).nil?

      user = User.find(user_id)
      position = find_last_position(user)
      Share.create_share_entry(user_id, params[:id], position)
    end
  end

  # function to create a entry in share table on successfull todo entry creation
  def self.create_entry_in_share(todo, current_user)
    share = Share.new('user_id' => current_user.id, 'todo_id' => todo.id, is_owner: true)
    if share.save
      position = find_last_position(current_user)
      share.update(position: position)
    end
  end

  # function to remove share entry
  def self.remove_entry_from_share(shared, params)
    users = params[:users]
    shared.each do |share|
      unless users.include? share.user_id.to_s
        Share.find_by(user_id: share.user_id, todo_id: params[:id]).destroy
      end
    end
  end

  # function to find last todos position of a user
  def self.find_last_position(user)
    top_todo = user.shares.order(:position).last
    if top_todo.nil?
      1
    else
      top_todo.position + 1
    end
  end
end
