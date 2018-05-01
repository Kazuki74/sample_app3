class AddInReplyToToMicroposts < ActiveRecord::Migration[5.1]
  def up
    add_column :microposts, :in_reply_to, :integer, defaut: 0
    add_index :microposts, :in_reply_to

  end

  def down
    remove_column :microposts, :in_reply_to, :integer, defaut: 0
    remove_index :microposts, :in_reply_to
  end
end
