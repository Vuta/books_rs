class Book < ApplicationRecord
  belongs_to :genre
  has_many :reviews

  has_attached_file :cover, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/assets/missing.jpg"
  validates_attachment_content_type :cover, content_type: /\Aimage\/.*\z/
end
