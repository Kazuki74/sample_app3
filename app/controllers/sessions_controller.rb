class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  		if user.activated?
        log_in user
        #[remember me] チェックボックスの送信結果を処理する
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
    		redirect_back_or user
      else
        message = "Account not activated."
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
  	else
  		#レンダリングが終わっているページで特別にフラッシュメッセージを表示。
  		#flashのメッセージとは異なり、flash.nowのメッセージはその後リクエストが発生したときに消滅
  		flash.now[:danger] = "Invalid email/password combination"
  		render 'new'
  	end
  end

  def destroy
  	log_out if logged_in?
  	redirect_to root_url
  end
end
