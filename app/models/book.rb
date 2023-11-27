class Book < ApplicationRecord
  # Active Storageを使用してBookモデルに画像を添付します
  has_one_attached :image

  # Userモデルとの関連付けを表すbelongs_toアソシエーション
  belongs_to :user

  # Favoriteモデルとの関連付けを表すhas_manyアソシエーション。dependent: :destroyは関連づけられたお気に入りが削除される際にそれらも削除する
  has_many :favorites, dependent: :destroy

  # BookCommentモデルとの関連付けを表すhas_manyアソシエーション。dependent: :destroyは関連づけられたコメントが削除される際にそれらも削除する
  has_many :book_comments, dependent: :destroy

  # ViewCountモデルとの関連付けを表すhas_manyアソシエーション。dependent: :destroyは関連づけられたビューカウントが削除される際にそれらも削除する
  has_many :view_counts, dependent: :destroy

  # 直近1週間以内に作成されたお気に入りを取得するためのスコープを定義
  has_many :week_favorites, -> { where(created_at: 1.week.ago.beginning_of_day..Time.current.end_of_day) }

  # 作成日時の降順でソートするスコープを定義
  scope :latest, -> { order(created_at: :desc) }

  # 作成日時の昇順でソートするスコープを定義
  scope :old, -> { order(created_at: :asc) }

  # 星の数で降順にソートするスコープを定義
  scope :star_count, -> { order(star: :desc) }

  # タイトル、本文、カテゴリが存在するかを検証するバリデーションを定義
  validates :title, presence: true
  validates :body, presence: true, length: { maximum: 200 }
  validates :category, presence: true

  # 特定のユーザーがこの本をお気に入りにしているかどうかを確認するメソッドを定義
  def favorited_by?(user)
    favorites.where(user_id: user.id).exists?
  end

  # コンテンツと検索方法に基づいて本を検索するためのメソッドを定義
  def self.search_for(content, method)
    if method == "perfect"
      Book.where(name: content)
    elsif method == 'forward'
      Book.where('name LIKE ?', content + '%')
    elsif method == 'backward'
      Book.where('name LIKE ?', '%' + content)
    else
      Book.where('name LIKE ?', '%' + content + '%')
    end
  end
end

