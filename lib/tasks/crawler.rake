require 'open-uri'

namespace :books do
  task :crawl => :environment do
    puts "Loggin in.."
    agent = Mechanize.new
    main_page = agent.get("https://www.goodreads.com")
    login_form = main_page.form
    login_form.field_with(name: "user[email]").value = ENV["GOODREADS_EMAIL"]
    login_form.field_with(name: "user[password]").value = ENV["GOODREADS_PASS"]
    login_form.submit
    puts "Done"

    retries = 40
    begin
      genres = Nokogiri::HTML(agent.get("https://www.goodreads.com/genres").body)
      genres_link = genres.css(".bigBoxContent a.gr-hyperlink").map { |link| link['href'] }
      genres_link << "/genres/computer-science"

      genres_link.each do |genre_link|
        puts "Crawling #{genre_link}..."

        genre_name = genre_link.split("/").last
        genre = Genre.find_by(name: genre_name) || Genre.create(name: genre_name)
        10.times do |i|
          puts "Crawling page #{i+1} of #{genre_name}"
          genre_page = Nokogiri::HTML(agent.get("https://www.goodreads.com/shelf/show/" + genre_name + "?page=#{i+1}").body)

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
              if test_book == nil
                book_page = Nokogiri::HTML(agent.get("https://www.goodreads.com" + book_link).body)
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
                  if book_page.css(".clearFloats .infoBoxRowTitle").first.text.include? "ISBN"
                    book[:isbn] = book_page.css(".clearFloats .infoBoxRowItem").text.split.first
                  else
                    book[:isbn] = book_page.css(".clearFloats .infoBoxRowItem")[1].text.split.first
                  end
                end

                book[:genre_id] = genre.id

                puts "Creating book #{book[:title]}"
                Book.create(book)
                puts "Done"

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

  end
end
