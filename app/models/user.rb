class User < ApplicationRecord
	attr_accessor :remember_token, :activation_token
	#email属性を小文字に変換してメールアドレスの一意性を保証する
	#before_save {email.downcase!} でもOK
	# before_save {self.email = email.downcase}
	before_save   :downcase_email
	before_create :create_activation_digest

	validates :name, presence: true, length: {maximum: 50}

	#メールフォーマットを正規表現で検証する
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false }

	#セキュアにハッシュ化したパスワードを、データベース内のpassword_digestという属性に保存できるようになる
	#2つのペアの仮想的な属性 (passwordとpassword_confirmation) が使えるようになる。また、存在性と値が一致するかどうかのバリデーションも追加される
	#authenticateメソッドが使えるようになる (引数の文字列がパスワードと一致するとUserオブジェクトを、間違っているとfalseを返すメソッド)
	#モデル内にpassword_digestという属性が含まれていることが必要
	has_secure_password

	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

	# 渡された文字列のハッシュ値を返す
	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	#ランダムなトークンを返す
	def self.new_token
		SecureRandom.urlsafe_base64
	end

	# 永続セッションのためにユーザーをデータベースに記憶する
	def remember
		#selfというキーワードを使わないと、remember_tokenという名前のローカル変数が作成されてしまう
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	# 渡されたトークンがダイジェストと一致したらtrueを返す
	def authenticated?(attribute, token)
		#メタプログラミングを利用
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	# ユーザーのログイン情報を破棄する
	def forget
		update_attribute(:remember_digest, nil)
	end

	# アカウントを有効にする
	def activate
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end

	# 有効化用のメールを送信する
	def send_activation_email
		UserMailer.account_activation(self).deliver.now
	end


	private
	    # メールアドレスをすべて小文字にする
	    def downcase_email
	      self.email = email.downcase
	    end

	    # 有効化トークンとダイジェストを作成および代入する
	    def create_activation_digest
	      self.activation_token  = User.new_token
	      self.activation_digest = User.digest(activation_token)
	    end
end
