require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
	def setup
		#上のusersはfixtureのファイル名users.ymlを表し、
		#:michaelというシンボルはリユーザーを参照するためのキーを表す
		@user = users(:michael)
	end

	test "login with invalid information" do
		#ログイン用のパスを開く
	    get login_path
	    #新しいセッションのフォームが正しく表示されたことを確認
	    assert_template 'sessions/new'
	    #わざと無効なparamsハッシュを使ってセッション用パスにPOSTする
	    post login_path, params: { session: { email: "", password: "" } }
	    #新しいセッションのフォームが再度表示され、フラッシュメッセージが追加されることを確認する
	    assert_template 'sessions/new'
	    assert_not flash.empty?
	    #別のページ (Homeページなど) にいったん移動する
	    get root_path
	    #移動先のページでフラッシュメッセージが表示されていないことを確認する
	    assert flash.empty?
	end

	test "login with valid information" do
		#ログイン用のパスを開く
	    get login_path
	    #セッション用パスに有効な情報をpostする
	    post login_path, params: { session: { email:    @user.email,
	                                          password: 'password' } }
	    assert_redirected_to @user
	    follow_redirect!
	    assert_template 'users/show'
	    #ログイン用リンクが表示されなくなったことを確認する
	    assert_select "a[href=?]", login_path, count: 0
	    #ログアウト用リンクが表示されていることを確認する
	    assert_select "a[href=?]", logout_path
	    #プロフィール用リンクが表示されていることを確認する
	    assert_select "a[href=?]", user_path(@user)
  end
end

