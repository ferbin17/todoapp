class Share < ApplicationRecord
  has_many :todos
  belongs_to :user
  belongs_to :todo
end
