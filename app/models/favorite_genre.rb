class FavoriteGenre < ApplicationRecord
  belongs_to :user
  belongs_to :genre

  validates :user_id, uniqueness: { scope: :genre_id }

  def self.select_genre_ids(user_ids)
    where(user_id: user_ids).pluck(:user_id, :genre_id)
  end
end
