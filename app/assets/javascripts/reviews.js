$(document).on('turbolinks:load', function() {
  $('.ui.star.rating').rating();

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
