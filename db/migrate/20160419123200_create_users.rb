class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :stat_ink_id
      t.text :stat_ink_result
      t.string :line_uid
      t.string :line_name
      t.string :stat_ink_key

      t.timestamps null: false
      t.integer :line_message_state
    end
    add_index :users, :line_uid, unique: true
  end
end
