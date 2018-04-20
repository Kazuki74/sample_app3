require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    #fixtureでuser変数を定義する
    @user = users(:michael)
    #渡されたユーザーをrememberメソッドで記憶する
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    #current_userが、渡されたユーザーと同じであることを確認
    assert_equal @user, current_user
    assert is_logged_in?
  end

  # ユーザーの記憶ダイジェストが記憶トークンと正しく対応していない場合に
  # 現在のユーザーがnilになるかどうかをテスト
  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
