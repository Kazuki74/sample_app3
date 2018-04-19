class AddPasswordDigestToUsers < ActiveRecord::Migration[5.1]
  #password_digestカラムを追加するマイグレーション
  def change
    add_column :users, :password_digest, :string
  end
end
