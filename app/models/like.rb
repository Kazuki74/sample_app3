class Like < ApplicationRecord
	# likeモデルを通じてuserとmicropostを取得
	belongs_to :user
	belongs_to :micropost
	counter_culture :micropost
	validates :user_id, presence: true
	validates :micropost_id, presence: true
end
