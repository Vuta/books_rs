class User < ApplicationRecord
  before_save :downcase_email
  has_secure_password

  has_many :favorite_genres, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

  def downcase_email
    self.email = email.downcase
  end

  def self.select_profile
    [first(500), last(count - 500).sample(100)].flatten
  end

  def find_common_ids(profile, thing, column_id)
    self.send(thing).pluck(column_id) & profile.send(thing).pluck(column_id)
  end

  def match_profile(sample_profiles)
    sample_profiles.delete(self)

    fav_genres = []
    rated_books = []
    sample_profiles.each do |profile|
      common_fav_genres = self.find_common_ids(profile, :favorite_genres, :genre_id)
      common_rated_books = self.find_common_ids(profile, :reviews, :book_id)
      fav_genres << [common_fav_genres.length, profile.id] if common_fav_genres.length != 0
      rated_books << [common_rated_books.length, profile.id] if common_rated_books.length != 0
    end

    genre_profiles = fav_genres.select { |i| i[0] == fav_genres.max[0] }.map { |i| i[1] }
    book_profiles = rated_books.select { |i| i[0] <= rated_books.max[0] && i[0] >= (rated_books.max[0] / 2) }.map { |i| i[1] }

    profile_ids = genre_profiles & book_profiles
  end

  def recommend_book
    sample_profiles = User.select_profile
    profile_id = self.match_profile(sample_profiles).first

    profile = User.find(profile_id)
    other_rated_books = profile.reviews.pluck(:book_id) - self.find_common_ids(profile, :reviews, :book_id)

    common_fav_genres = self.find_common_ids(profile, :favorite_genres, :genre_id)

    recommended_books = []
    Review.where(book_id: other_rated_books, user_id: profile_id).order(rate: :desc).each do |review|
      recommended_books << review.book if common_fav_genres.include? review.book.genre.id
    end

    recommended_books.first(10)
  end
end
