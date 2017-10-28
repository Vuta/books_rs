# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
1000.times do |i|
  puts "==========================================================================="
  puts "Random user infomation..."
  user_name = Faker::Internet.user_name.gsub(".", " ").titleize
  user_email = Faker::Internet.email(user_name)
  user_password = "123456"

  if User.find_by(email: user_email).nil?
    puts "Create user #{i+1}"
    user = User.create(name: user_name, email: user_email, password: user_password)
    puts "Done"

    genre_ids = Genre.pluck(:id)

    puts "Random numbers of favorite genres of user #{i+1}"
    fav_genres_ids = genre_ids.sample(rand(1..10))
    puts "Done"

    fav_genres_ids.each do |fav_genre_id|
      puts "Create favorite genre"
      fav_genre = user.favorite_genres.create(genre_id: fav_genre_id)
      puts "Done"
    end
  end
end

reviews_arr = []
Book.order(:id).pluck(:id).each do |book_id|
  genre = Book.find(book_id).genre
  reviews = Review.where(book_id: book_id)

  if reviews.count <= 100
    rand(50..100).times do |i|
      puts "#{i+1}"
      user = FavoriteGenre.where(genre_id: genre.id).sample.user
      review = Review.find_by(book_id: book_id, user_id: user.id)
      if review.nil?
        puts "Create review for book #{book_id} of user #{user.id}"
        # Review.create(book_id: book_id, user_id: user.id, rate: rand(1..5))
        reviews_arr << [book_id, user.id, rand(1..5)]
        puts "Done"
      end
    end
  end
end

columns = [:book_id, :user_id, :rate]
Review.import columns, reviews_arr, validate: false

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
