class Share < ApplicationRecord
  has_many :todos
  belongs_to :user
  belongs_to :todo

  scope :shared_users, lambda { |id| where("todo_id=? AND is_owner=false", id).order(:user_id) }
  scope :select_user_id, lambda { select('user_id') }
  scope :create_share_entry, lambda { |user_id, todo_id, position| create(user_id: user_id, todo_id: todo_id, position: position) }

  def self.manage_share(params)
    shared = Share.select_user_id.shared_users(params[:id])
    create_entry_to_share(shared, params)
    remove_entry_from_share(shared, params)
  end

  def self.create_entry_to_share(shared, params)
    users = params[:users]
    users.each do |user_id|
      break if user_id == "0"
      if shared.find_by(user_id: user_id) == nil
        position = find_last_position(user_id)
        Share.create_share_entry(user_id, params[:id], position)
      end
    end
  end

  def self.remove_entry_from_share(shared, params)
    users = params[:users]
    shared.each do |share|
      unless users.include? ("#{share.user_id}")
        (Share.find_by(user_id: share.user_id, todo_id: params[:id])).destroy
      end
    end
  end

  def self.find_last_position(user_id)
    user = User.find_by(id: user_id)
    top_todo = (user.shares.order(:position)).last
    return 1 if top_todo == nil
    return top_todo.position+1
  end
end
