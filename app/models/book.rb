class Book < ApplicationRecord
has_one_attached :image
belongs_to :user
has_many :favorites, dependent: :destroy
has_many :book_comments, dependent: :destroy
has_many :week_favorites, -> {where(created_at: 1.week.ago.beginning_of_day..Time.current.end_of_day) }
scope :latest, -> {order(created_at: :desc)}
scope :old, -> {order(created_at: :asc)}
scope :star_count, -> {order(star: :desc)}

  validates :title, presence: true
  validates :body, presence: true, length: { maximum: 200 }

  def favorited_by?(user)
    favorites.where(user_id: user.id).exists?
  end
  
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
