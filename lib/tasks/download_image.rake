namespace :images do
  task :download => :environment do
    images_link = Book.all.pluck(:cover_image)

    agent = Mechanize.new

    images_link.each do |link|
      puts "Downloading #{link}"
      image_name = link.split("/")[-2] + "-" + link.split("/")[-1]
      agent.get(link).save(Pathname.new(Rails.root + "app/assets/images/books/#{image_name}"))
      puts "Done"
    end
  end

  task :update_cover => :environment do
    images_link = Book.all.pluck(:id, :cover_image)
    images_link.each do |id, link|
      puts "Updating book #{id}"
      image_name = link.split("/")[-2] + "-" + link.split("/")[-1]
      book = Book.find(id)
      book.cover = File.open(Pathname.new(Rails.root + "app/assets/images/books/#{image_name}"))
      book.save
      puts "Done"
    end
  end
end
