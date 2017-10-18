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
end
