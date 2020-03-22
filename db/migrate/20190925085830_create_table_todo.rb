class CreateTableTodo < ActiveRecord::Migration[6.0]
  def change
    create_table :todos do |t|
      t.string :body
      t.datetime :datetime
      t.timestamps
    end
  end
end
