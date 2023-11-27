class User < ApplicationRecord
  # Deviseモジュールを使用してユーザー認証機能を追加します
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # このユーザーが投稿した本に対する関連付けを表すhas_manyアソシエーション
  has_many :books

  # お気に入りに関する関連付けを表すhas_manyアソシエーション
  has_many :favorites, dependent: :destroy

  # 本に対するコメントに関する関連付けを表すhas_manyアソシエーション
  has_many :book_comments, dependent: :destroy

  # フォロワーとの関連付けを表すhas_manyアソシエーション
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :reverse_of_relationships, source: :follower

  # フォローしているユーザーとの関連付けを表すhas_manyアソシエーション
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :followings, through: :relationships, source: :followed

  # メッセージの送信者と受信者に関する関連付けを表すhas_manyアソシエーション
  has_many :send_user, dependent: :destroy
  has_many :receive_user, dependent: :destroy

  # ビューカウントに関する関連付けを表すhas_manyアソシエーション
  has_many :view_counts, dependent: :destroy

  # プロフィール画像を添付するためのActive Storageの関連付け
  has_one_attached :profile_image

  # バリデーション：ユーザー名が存在し、一意であること、長さは2から20文字の範囲内であること
  validates :name, presence: true, uniqueness: true, length: { in: 2..20 }

  # バリデーション：自己紹介文の長さが50文字以内であること
  validates :introduction, length: { maximum: 50 }

  # プロフィール画像がない場合はデフォルトの画像を表示するメソッド
  def get_profile_image(width, height)
    unless profile_image.attached?
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      profile_image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
    end
    profile_image.variant(resize_to_limit: [width, height]).processed
  end

  # ユーザーをフォローするメソッド
  def follow(user)
    relationships.create(followed_id: user.id)
  end

  # ユーザーのフォローを解除するメソッド
  def unfollow(user)
    relationships.find_by(followed_id: user.id).destroy
  end

  # 特定のユーザーをフォローしているかどうかを確認するメソッド
  def following?(user)
    followings.include?(user)
  end

  # ユーザーを検索するメソッド
  def self.search_for(content, method)
    if method == "perfect"
      User.where(name: content)
    elsif method == 'forward'
      User.where('name LIKE ?', content + '%')
    elsif method == 'backward'
      User.where('name LIKE ?', '%' + content)
    else
      User.where('name LIKE ?', '%' + content + '%')
    end
  end
end
