class Review < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :user_id, uniqueness: { scope: :book_id }

  def self.select_book_ids(book_ids)
    where(user_id: book_ids).pluck(:user_id, :book_id)
  end
end
