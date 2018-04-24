source 'http://rubygems.org'

gem 'rails',        '5.1.4'
#has_secure_passwordを使ってパスワードをハッシュ化するために必要
gem 'bcrypt',         '3.1.11'
#実際にいそうなユーザー名を作成するgem
gem 'faker',          '1.7.3'
#ページネーション
gem 'will_paginate',           '3.1.6'
# 画像アップローダー
gem 'carrierwave',             '1.2.2'
# 画像をリサイズ
gem 'mini_magick',             '4.7.0'
gem 'bootstrap-will_paginate', '1.0.0'
gem 'puma',         '3.9.1'
gem 'sass-rails',   '5.0.6'
gem 'uglifier',     '3.2.0'
gem 'coffee-rails', '4.2.2'
gem 'jquery-rails', '4.3.1'
gem 'turbolinks',   '5.0.1'
gem 'jbuilder',     '2.7.0'
gem 'bootstrap-sass', '3.3.7'
gem 'rails-controller-testing'
gem 'minitest', '5.10.1'

group :development, :test do
  gem 'sqlite3', '1.3.13'
  gem 'byebug',  '9.0.6', platform: :mri
end

group :development do
  gem 'web-console',           '3.5.1'
  gem 'listen',                '3.0.8'
  gem 'spring',                '2.0.2'
  gem 'spring-watcher-listen', '2.0.1'
end

group :production do
  gem 'pg', '0.20.0'
  # 本番環境で画像をアップロード
  gem 'fog', '1.42'
end
