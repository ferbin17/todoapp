class CreateShares < ActiveRecord::Migration[6.0]
  def change
    create_table :shares do |t|
      t.references :todo
      t.references :user
      t.bigint :position, default: false, null: false
      t.boolean :is_owner, default: false, null: false
      t.timestamps
    end
  end
end
