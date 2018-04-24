class Micropost < ApplicationRecord
	belongs_to :user
	# データベースから要素を取得したときの、デフォルトの順序を指定するメソッド
	default_scope -> { order(created_at: :desc) }
	# Micropostモデルに画像を追加する
	mount_uploader :picture, PictureUploader
	validates :user_id, presence: true
	validates :content, presence: true, length: {maximum: 140}
	#独自のバリデーションを定義するため、validateメソッド使用
	validate :picture_size

	private
		def picture_size
			if picture.size > 5.megabytes
				errors.add(:picture, "should be less than 5MB")
			end
		end
end
