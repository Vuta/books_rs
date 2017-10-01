require 'open-uri'

namespace :books do
  task :crawl => :environment do
    # books = []
    retries = 40
    begin
      genres = Nokogiri::HTML(open("https://www.goodreads.com/genres"))
      genres_link = genres.css(".bigBoxContent a.gr-hyperlink").map { |link| link['href'] }

      genres_link.each do |genre_link|
        puts "Crawling #{genre_link}..."

        genre_name = genre_link.split("/").last
        genre = Genre.find_by(name: genre_name) || Genre.create(name: genre_name)
        if genre.books.count == 0
          genre_page = Nokogiri::HTML(open("https://www.goodreads.com" + genre_link))

          if genre_page
          books_link = genre_page.css(".bookBox a").map { |link| link['href'] }

          books_link.each do |book_link|

            book_page = Nokogiri::HTML(open("https://www.goodreads.com" + book_link))
            puts "Crawling #{book_link}"

            book = {}
            book[:author] = book_page.css("#bookAuthors a.authorName span").children.text
            book[:title] = book_page.css("h1.bookTitle").children.text.strip
            book[:description] = book_page.css("#description span[style]").children.text

            if book_page.css("#details .row").count == 2
              book[:released_date] = book_page.css("#details .row")[1].children.text.gsub("Published", "").split("by")[0].strip if book_page.css("#details .row")[1].children.text.gsub("Published", "").split("by")[0]
              book[:publisher] = book_page.css("#details .row")[1].children.text.gsub("Published", "").split("by")[1].strip if book_page.css("#details .row")[1].children.text.gsub("Published", "").split("by")[1]
            end

            if book_page.css("#details .row").count == 1
              book[:released_date] = book_page.css("#details .row")[0].children.text.gsub("Published", "").split("by")[0].strip if book_page.css("#details .row")[0].children.text.gsub("Published", "").split("by")[0]
              book[:publisher] = book_page.css("#details .row")[0].children.text.gsub("Published", "").split("by")[1].strip if book_page.css("#details .row")[0].children.text.gsub("Published", "").split("by")[1]
            end

            book[:cover_image] = book_page.css(".bookCoverPrimary a img").attr("src").value
            book[:isbn] = book_page.css(".clearFloats .infoBoxRowItem").text.split.first if book_page.css(".clearFloats .infoBoxRowTitle").text == "ISBN"

            book[:genre_id] = genre.id

            puts "Creating book #{book[:title]}"
            Book.create(book) unless Book.find_by(title: book[:title])
            puts "Done"
            # books << book
          end
          end
        end
      end
    rescue Net::OpenTimeout
      puts "In OpenTimeout.."
      retries -= 1
      puts retries
      if retries > 0
        sleep 1 and retry
      else
        raise
      end
    rescue Net::ReadTimeout
      puts "In ReadTimeout"
      retries -= 1
      puts retries
      if retries > 0
        sleep 1 and retry
      else
        raise
      end
    end
    # books.each do |book|
      # puts "Creating book #{book[:title]}"
      # Book.find_by(title: book[:title]) || Book.create(book)
      # puts "Done"
    # end
  end
end
