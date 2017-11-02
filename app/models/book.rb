class Book < ApplicationRecord
  belongs_to :genre
  has_many :reviews, dependent: :destroy

  has_attached_file :cover, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/assets/missing.jpg"
  validates_attachment_content_type :cover, content_type: /\Aimage\/.*\z/

  def avg_rating
    # binding.pry
    if self.reviews.length != 0
      rates = self.reviews.pluck(:rate)
      (rates.inject(:+).to_f / rates.count).ceil(2)
    else
      0
    end
  end

  def released_year
    self.released_date.split.last
  end

  def text_reviews
    self.reviews.where.not(text: nil)
  end

  def self.popular_of_month
    first_of_month = (Date.current - 1.months).beginning_of_month
    end_of_month = (Date.current - 1.months).end_of_month
    Review.where('created_at BETWEEN ? AND ?', first_of_month, end_of_month).includes(:book).group(:book).count.sort_by { |i| -i[1] }.first(10)
  end
end
