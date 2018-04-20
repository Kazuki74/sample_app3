require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
  	log_in_as(@user)
  	#編集ページにアクセス
    get edit_user_path(@user)
    assert_template 'users/edit'
    #無効な情報を送信してみて、editビューが再描画されるかどうかをチェック
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }
    assert_template 'users/edit'
  end

   test "successful edit with friendly forwarding" do
   	#編集ページにアクセスし、ログイン
   	get edit_user_path(@user)
   	log_in_as(@user)
   	#編集ページにリダイレクトされているかどうかをチェック
    get edit_user_path(@user)
    #有効な情報を送信
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    #flashメッセージが空でないかどうか
    assert_not flash.empty?
    #プロフィールページにリダイレクトされるかどうか
    assert_redirected_to @user
    #データベース内のユーザー情報が正しく変更されたかどうか
    #データベースから最新のユーザー情報を読み込み直す
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end
