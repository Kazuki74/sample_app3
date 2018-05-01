class Micropost < ApplicationRecord
	# 本文から返信先を抜き出す
	before_validation :set_in_reply_to
	# micropostsテーブルにはuser_id属性があるので、これを辿って対応する所有者 (ユーザー) を特定
	# Userモデルに繋げる外部キーが、Micropostモデルのuser_id属性
	belongs_to :user
	has_many :likes, dependent: :destroy
	has_many :like_users, through: :likes, source: :user
	# データベースから要素を取得したときの、デフォルトの順序を指定するメソッド
	default_scope -> { order(created_at: :desc) }
	# Micropostモデルに画像を追加する
	mount_uploader :picture, PictureUploader
	validates :user_id, presence: true
	validates :content, presence: true, length: {maximum: 140}
	validates :in_reply_to, presence: true
	#独自のバリデーションを定義するため、validateメソッド使用
	validate :picture_size, :reply_to_user

	def favorite(user)
		likes.create(user_id: user.id)
	end

	# 現在のユーザーがいいねしてたらtrueを返す
	def favorite?(user)
		like_users.include?(user)
	end

	def unfavorite(user)
		likes.find_by(user_id: user.id).destroy
	end

	def Micropost.including_replies(id)
		# in_reply_toが0または自分のIDである(返信先の指定がないor返信先が自分)
		# もしくはuser_idが自分のIDである(自分が投稿者)
		Micropost.where(in_reply_to: [id, 0]).or(Micropost.where(user_id: id))
	end

	def set_in_reply_to
		# 本文中の@を探す
		# 引数が含まれていれば、その開始位置を整数で返す（0が1番目、1が2番目、...）
		if @index = self.content.index("@")
			reply_id = []
			while is_i?(content[@index+1])
				# その位置から数字が続くだけ文字を取得
				@index += 1
				reply_id << self.content[@index]
			end
			# 最後に連結&Integerにキャスト
			self.in_reply_to = reply_id.join.to_i
		else
			self.in_reply_to = 0
		end
	end

	def is_i?(s)
		Integer(s) != nil rescue false
	end

	def reply_to_user
		# 返信先が指定されていない場合、チェックしない
		return if self.in_reply_to == 0
		# 指定したIDのユーザーが見つからない場合、エラーとする
		unless user = User.find_by(id: self.in_reply_to)
			# :baseは、エラーメッセージを表示する際に、属性名を表示しない
			errors.add(:base, "User ID you specified doesn't exist.")
		else
			# 自分自身に返信を行なった場合、エラーとする
			if user_id == self.in_reply_to
				errors.add(:base, "You can't reply to yourself. #{self.in_reply_to} #{user.id}")
			else
				# 指定したIDのユーザー名が間違っていた場合、エラーとする
				unless reply_to_user_name_correct?(user)
				errors.add(:base, "User ID doesn't match its name.")
				end
			end
		end
	end

	def reply_to_user_name_correct?(user)
		# 指定されたIDのユーザー名を取得し、空白を「-」で埋める
		user_name = user.name.gsub(" ", "-")
		# 先ほど取得していた@indexを2つ進め、実際のユーザー名の長さだけ本文を抜き出し、比較
		content[@index+2, user_name.length] == user_name
	end

	private
		def picture_size
			if picture.size > 5.megabytes
				errors.add(:picture, "should be less than 5MB")
			end
		end
end
