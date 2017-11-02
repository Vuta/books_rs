namespace :books do
  task :popular_of_month => :environment do
    first_of_month = (Date.current - 1.months).beginning_of_month
    end_of_month = (Date.current - 1.months).end_of_month
    binding.pry
    Review.where('created_at BETWEEN ? AND ?', first_of_month, end_of_month).includes(:book).group(:book).count.sort_by { |i| -i[1] }.first(10)
  end
end
