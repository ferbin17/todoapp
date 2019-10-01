class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :body
      t.references :todo
      t.references :user
      t.timestamps
    end
  end
end
