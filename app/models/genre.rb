class Genre < ApplicationRecord
  has_many :books
  has_many :favorite_genres
end
