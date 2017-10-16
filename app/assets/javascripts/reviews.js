$(document).on('turbolinks:load', function() {
  $('.ui.star.rating').rating();
  $('.ui.star.rating.disable').rating('disable');

  var counter = 1;

  $('a.genre_link').click(function(e) {
    e.preventDefault();

    var links = $('a.genre_link');

    for(var i = 0; i < links.length; i++) {
      $(links[i]).removeClass('active');
    }

    var genre = $(this).data('genre');
    $(this).addClass('active');

    data = {'genre': genre}
    $.ajax({
      type: 'GET',
      url: '/rate_books',
      data: data,
      success: function(res) {
        var html = $(res).find('.' + data.genre + '.fav_content');
        if($('twelve.genre_books_content').find('.' + data.genre + '.fav_content')[0]) {
          $('.twelve.wide.column.genre_books_content').append(html);
        } else {
          $('.twelve.wide.column.genre_books_content').html(html);
        }

        $('.ui.star.rating').rating();
      }
    })
    counter = 1;
  })

  $('a.load_more_books').click(function(e) {
    counter += 1;
    var genre = $('a.genre_link.active').data('genre');

    $.ajax({
      type: 'GET',
      url: '/rate_books',
      data: {'page': counter, 'genre': genre},
      success: function(res) {
        var html = $(res).find('.' + genre + '.fav_content');
        $('.twelve.wide.column.genre_books_content').append(html);

        $('.ui.star.rating').rating();
      }
    });
  })

})

$(document).on('click', '.ui.star.rating', function() {
  var book_id = $(this).data('book-id');
  var rate = $(this).find('i.icon.active').length;

  $.ajax({
    type: 'POST',
    url: '/rate_books',
    data: {'book_id': book_id, 'rate': rate},
    success: function(res) {
      console.log(1)
    }
  })
})
