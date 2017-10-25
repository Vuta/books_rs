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
    [first(500), last(count - 500).sample(300)].flatten
  end

  def match_profile(sample_profiles)
    sample_profiles.delete(self)
    sample_profiles_ids = sample_profiles.pluck(:id)
    sample_genres = []
    sample_books = []

    # fav_genres = FavoriteGenre.where(user_id: sample_profiles.pluck(:id)).pluck(:user_id, :genre_id)
    fav_genres = FavoriteGenre.select_genre_ids(sample_profiles_ids)
    fav_genre_ids_by_profile = Hash.new { |hash, key| hash[key] = [] }
    rated_books = Review.select_book_ids(sample_profiles_ids)
    rated_book_ids_by_profile = Hash.new { |hash, key| hash[key] = [] }

    fav_genres.each do |fav_genre|
      user_id, genre_id = fav_genre
      fav_genre_ids_by_profile[user_id].push(genre_id)
    end
    rated_books.each do |rate_book|
      user_id, book_id = rate_book
      rated_book_ids_by_profile[user_id].push(book_id)
    end

    self_fav_genres = self.favorite_genres.pluck(:genre_id)
    self_rated_books = self.reviews.pluck(:book_id)
    sample_profiles.each do |profile|
      common_fav_genres = self_fav_genres & fav_genre_ids_by_profile[profile.id]
      common_rated_books = self_rated_books & rated_book_ids_by_profile[profile.id]
      sample_genres << [common_fav_genres.length, profile.id] if common_fav_genres.length != 0
      sample_books << [common_rated_books.length, profile.id] if common_rated_books.length != 0
    end

    genre_profiles = sample_genres.select { |i| i[0] == sample_genres.max[0] }.map { |i| i[1] }
    book_profiles = sample_books.select { |i| i[0] <= sample_books.max[0] && i[0] >= (sample_books.max[0] / 2) }.map { |i| i[1] }

    profile_ids = genre_profiles & book_profiles
    if profile_ids.present?
      common_fav_genres = self_fav_genres & fav_genre_ids_by_profile[profile_ids.first]
      common_rated_books = self_rated_books & rated_book_ids_by_profile[profile_ids.first]
      return [profile_ids.first, common_fav_genres, common_rated_books]
    end
  end

  def recommend_book
    sample_profiles = User.select_profile
    match_profile = self.match_profile(sample_profiles)
    if match_profile
      profile_id = match_profile.first

      profile = User.find_by(id: profile_id)
      # other_rated_books = profile.reviews.pluck(:book_id) - self.find_common_ids(profile, :reviews, :book_id)
      common_fav_genres = match_profile.second
      other_rated_books = profile.reviews.pluck(:book_id) - match_profile.last

      # common_fav_genres = self.find_common_ids(profile, :favorite_genres, :genre_id)

      recommended_books = []
      Review.includes(:book).where(book_id: other_rated_books, user_id: profile_id).order(rate: :desc).each do |review|
        recommended_books << review.book if common_fav_genres.include? review.book.genre_id
      end

      recommended_books.first(15)
    end
  end
end
