class Micropost < ApplicationRecord
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
	#独自のバリデーションを定義するため、validateメソッド使用
	validate :picture_size

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

	private
		def picture_size
			if picture.size > 5.megabytes
				errors.add(:picture, "should be less than 5MB")
			end
		end
end
