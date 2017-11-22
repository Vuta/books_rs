class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/assets/default_avatar.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  before_save :downcase_email
  # has_secure_password

  has_many :favorite_genres, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :books, through: :reviews
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

  def downcase_email
    self.email = email.downcase
  end

  # select sample profiles for book recommendation
  def self.select_profile
    [first(500), last(count - 500).sample(450)].flatten
  end

  # def match_profile(sample_profiles)
  #   sample_profiles.delete(self)
  #   sample_profiles_ids = sample_profiles.pluck(:id)
  #   sample_genres = []
  #   sample_books = []

  #   # fav_genres = FavoriteGenre.where(user_id: sample_profiles.pluck(:id)).pluck(:user_id, :genre_id)
  #   fav_genres = FavoriteGenre.select_genre_ids(sample_profiles_ids)
  #   fav_genre_ids_by_profile = Hash.new { |hash, key| hash[key] = [] }
  #   rated_books = Review.select_book_ids(sample_profiles_ids)
  #   rated_book_ids_by_profile = Hash.new { |hash, key| hash[key] = [] }

  #   fav_genres.each do |fav_genre|
  #     user_id, genre_id = fav_genre
  #     fav_genre_ids_by_profile[user_id].push(genre_id)
  #   end
  #   rated_books.each do |rate_book|
  #     user_id, book_id = rate_book
  #     rated_book_ids_by_profile[user_id].push(book_id)
  #   end

  #   self_fav_genres = self.favorite_genres.pluck(:genre_id)
  #   self_rated_books = self.reviews.pluck(:book_id)
  #   sample_profiles.each do |profile|
  #     common_fav_genres = self_fav_genres & fav_genre_ids_by_profile[profile.id]
  #     common_rated_books = self_rated_books & rated_book_ids_by_profile[profile.id]
  #     sample_genres << [common_fav_genres.length, profile.id] if common_fav_genres.length != 0
  #     sample_books << [common_rated_books.length, profile.id] if common_rated_books.length != 0
  #   end

  #   genre_profiles = sample_genres.select { |i| i[0] == sample_genres.max[0] }.map { |i| i[1] }
  #   book_profiles = sample_books.select { |i| i[0] <= sample_books.max[0] && i[0] >= (sample_books.max[0] / 2) }.map { |i| i[1] }

  #   profile_ids = genre_profiles & book_profiles
  #   if profile_ids.present?
  #     common_fav_genres = self_fav_genres & fav_genre_ids_by_profile[profile_ids.first]
  #     common_rated_books = self_rated_books & rated_book_ids_by_profile[profile_ids.first]
  #     return [profile_ids.first, common_fav_genres, common_rated_books]
  #   end
  # end

  # select match profile
  def match_profile(sample_profiles)
    sample_profiles.delete(self)
    sample_profiles_ids = sample_profiles.pluck(:id)

    # return array of [:user_id, :book_id] of sample profiles
    rated_books = Review.select_book_ids(sample_profiles_ids)
    rated_book_ids_by_profile = Hash.new { |hash, key| hash[key] = [] }

    # return array of [:user_id, :genre_id] of sample profiles
    fav_genres = FavoriteGenre.select_genre_ids(sample_profiles_ids)
    fav_genre_ids_by_profile = Hash.new { |hash, key| hash[key] = [] }

    # return a hash like: {user_id: [:genre_id, :genre_id, ...]} of favorite genres
    fav_genres.each do |fav_genre|
      user_id, genre_id = fav_genre
      fav_genre_ids_by_profile[user_id].push(genre_id)
    end

    # return hash like: {user_id: [:book_id, :book_id, ...]} of rated books
    rated_books.each do |rate_book|
      user_id, book_id = rate_book
      rated_book_ids_by_profile[user_id].push(book_id)
    end

    self_fav_genres = self.favorite_genres.pluck(:genre_id)
    self_rated_books = self.reviews.pluck(:book_id)
    sample_users = []
    result = []

    # return list of users who has common favorite genres with self
    sample_profiles.each do |user|
      common_fav_genres = self_fav_genres & fav_genre_ids_by_profile[user.id]
      sample_users << user if common_fav_genres.length != 0
    end

    sample_users.each do |user|
      jaccard = (rated_book_ids_by_profile[user.id] & self_rated_books).count.to_f / (rated_book_ids_by_profile[user.id] | self_rated_books).count
      result << [jaccard, user]
    end

    potential_profile = result.sort_by { |i| -i[0] }.first[1]
    common_fav_genres = self_fav_genres & fav_genre_ids_by_profile[potential_profile.id]
    common_rated_books = self_rated_books & rated_book_ids_by_profile[potential_profile.id]

    # return [match user, array of common fav genres, array of common rated books]
    return [potential_profile, common_fav_genres, common_rated_books]
  end

  def recommend_book
    sample_profiles = User.select_profile
    match_profile = self.match_profile(sample_profiles)
    if match_profile
      profile = match_profile.first
      common_fav_genres = match_profile.second

      # return other books rated by match user
      other_rated_books = profile.reviews.pluck(:book_id) - match_profile.last

      recommended_books = []

      # return books in the same favorite genres with self, rated by match user, desc order by rate
      Review.includes(:book).where(book_id: other_rated_books, user_id: profile.id).order(rate: :desc).each do |review|
        recommended_books << review.book if common_fav_genres.include? review.book.genre_id
      end

      recommended_books.first(15)
    end
  end

  def rated_books
    books_ids = self.reviews.pluck(:book_id).uniq
    books = Book.where(id: books_ids)
  end

  def format_rated_time(book)
    Review.find_by(user_id: self, book_id: book).updated_at.strftime("%b %d, %Y %I:%M %p")
  end
end
