module SessionsHelper
	#渡されたユーザーでログインする
	def log_in(user)
		#ユーザーのブラウザ内の一時cookiesに暗号化済みのユーザーIDを自動で作成
		session[:user_id] = user.id
	end

	# 現在ログイン中のユーザーを返す (いる場合)
	def current_user
		@current_user ||= User.find_by(id: session[:user_id])
	end

	# ユーザーがログインしていればtrue、その他ならfalseを返す
	def logged_in?
		#!演算子は理論値を反転
		!current_user.nil?
	end

	# 現在のユーザーをログアウトする
	def log_out
		#セッションからユーザーIDを削除
		session.delete(:user_id)
		@current_user = nil
	end
end
