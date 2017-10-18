class Genre < ApplicationRecord
  has_many :books, dependent: :destroy
  has_many :favorite_genres, dependent: :destroy
end
