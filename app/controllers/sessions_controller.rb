class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  		log_in user
  		redirect_to user
  	else
  		#レンダリングが終わっているページで特別にフラッシュメッセージを表示。
  		#flashのメッセージとは異なり、flash.nowのメッセージはその後リクエストが発生したときに消滅
  		flash.now[:danger] = "Invalid email/password combination"
  		render 'new'
  	end
  end

  def destroy
  	log_out
  	redirect_to root_url
  end
end
