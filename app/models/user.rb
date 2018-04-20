class User < ApplicationRecord
	#email属性を小文字に変換してメールアドレスの一意性を保証する
	before_save {self.email = email.downcase}
	#before_save {email.downcase!} でもOK

	validates :name, presence: true, length: {maximum: 50}

	#メールフォーマットを正規表現で検証する
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false }

	#セキュアにハッシュ化したパスワードを、データベース内のpassword_digestという属性に保存できるようになる
	#2つのペアの仮想的な属性 (passwordとpassword_confirmation) が使えるようになる。また、存在性と値が一致するかどうかのバリデーションも追加される
	#authenticateメソッドが使えるようになる (引数の文字列がパスワードと一致するとUserオブジェクトを、間違っているとfalseを返すメソッド)
	#モデル内にpassword_digestという属性が含まれていることが必要
	has_secure_password

	validates :password, presence: true, length: { minimum: 6 }

	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end
end
