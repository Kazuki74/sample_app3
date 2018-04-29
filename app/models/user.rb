class User < ApplicationRecord
	# ユーザーがマイクロポストを複数所有する (has_many) 関連付け
	has_many :microposts, dependent: :destroy
	has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
	has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
	# active_relationshipsテーブルを中間テーブルに位置づける
	# :sourceパラメーターを使い、「following配列の元はfollowed idの集合である」ということを明示的にRailsに伝える
	has_many :following, through: :active_relationships, source: :followed
	# :followers属性の場合、Railsが「followers」を単数形にして自動的に外部キーfollower_idを探してくれる
	has_many :followers, through: :passive_relationships
	attr_accessor :remember_token, :activation_token, :reset_token
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
		UserMailer.account_activation(self).deliver_now
	end

	# パスワード再設定の属性を設定する
	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest, User.digest(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
	end

	# パスワード再設定のメールを送信する
	def send_password_reset_email
		UserMailer.password_reset(self).deliver.now
	end

	# パスワード再設定の期限が切れている場合はtrueを返す
  	def password_reset_expired?
    	reset_sent_at < 2.hours.ago
	end

	# ユーザーのステータスフィードを返す
	def feed
		following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
		# user.followingコレクションに対応するidを得るためには、関連付けの名前の末尾に_idsを付け足す
	    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
	end

	# ユーザーをフォローする
	def follow(other_user)
		active_relationships.create(followed_id: other_user.id)
	end

	# ユーザーをフォロー解除する
	def unfollow(other_user)
		active_relationships.find_by(followed_id: other_user.id).destroy
	end

	# 現在のユーザーがフォローしてたらtrueを返す
	def following?(other_user)
		following.include?(other_user)
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
