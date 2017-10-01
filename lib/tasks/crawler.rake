require 'open-uri'

namespace :books do
  task :crawl => :environment do

    retries = 40
    begin
      genres = Nokogiri::HTML(open("https://www.goodreads.com/genres"))
      genres_link = genres.css(".bigBoxContent a.gr-hyperlink").map { |link| link['href'] }
      genres_link << "/genres/computer-science"

      genres_link.each do |genre_link|
        puts "Crawling #{genre_link}..."

        genre_name = genre_link.split("/").last
        genre = Genre.find_by(name: genre_name) || Genre.create(name: genre_name)
        3.times do |i|
          genre_page = Nokogiri::HTML(open("https://www.goodreads.com/shelf/show/" + genre_name + "?page=#{i+1}"))

          if genre_page
            books_link = genre_page.css("a.bookTitle").map { |link| link['href'] }

            # get large size cover instead of small
            covers_link = genre_page.css(".left img").map do |link|
              a = link['src'].split("/")
              a[4] = a[4].gsub("s", "l")
              a.join("/")
            end

            book_cover_links = []
            books_link.length.times do |i|
              book_cover_links << [books_link[i], covers_link[i]]
            end

            book_cover_links.each do |book_link, cover_link|
              test_book = Book.find_by(cover_image: cover_link)
              if test_book == nil || test_book.isbn == nil
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

                book[:cover_image] = cover_link
                if book_page.css(".clearFloats .infoBoxRowTitle").text.include? "ISBN"
                  if book_page.css(".clearFloats .infoBoxRowTitle").first.text == "ISBN"
                    book[:isbn] = book_page.css(".clearFloats .infoBoxRowItem").text.split.first
                  else
                    book[:isbn] = book_page.css(".clearFloats .infoBoxRowItem")[1].text.split.first
                  end
                end

                book[:genre_id] = genre.id
                if test_book == nil
                  puts "Creating book #{book[:title]}"
                  Book.create(book)
                  puts "Done"
                else
                  puts "Updating book #{book[:title]}"
                  test_book.update(isbn: book[:isbn])
                  puts "Done"
                end
              end

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
    books.each do |book|
      puts "Creating book #{book[:title]}"
      Book.find_by(title: book[:title]) || Book.create(book)
      puts "Done"
    end
    # doc = Nokogiri::HTML(open("https://www.goodreads.com/shelf/show/computer-science"))
    # links = doc.css(".right a").map { |link| link['href'] }
    # binding.pry
  end
end
