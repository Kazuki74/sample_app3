class UsersController < ApplicationController
  def new
  	@user = User.new
  end

  def show
  	#Usersコントローラにリクエストが正常に送信されると、params[:id]の部分はユーザーidの1に置き換わる
  	@user = User.find(params[:id])
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      log_in @user
  		flash[:success] = "Welcome to the Sample App!"
  		#redirect_to user_url(@user)と等価
  		redirect_to @user
  	else
  		render 'new'
  	end
  end

  private
  #paramsハッシュでは:user属性を必須とし、
  #名前、メールアドレス、パスワード、パスワードの確認の属性をそれぞれ許可し、それ以外を許可しない
  	def user_params
  		params.require(:user).permit(:name, :email, :password, :password_confirmation)
  	end
end
