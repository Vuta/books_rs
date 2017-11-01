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
    var q = $('input#q_title_cont').val();
    if(q) {
      var genre = '';
    } else {
      var genre = $('a.genre_link.active').data('genre');
    }

    $.ajax({
      type: 'GET',
      url: '/rate_books',
      data: {'page': counter, 'genre': genre, 'q': {'title_cont': q}},
      success: function(res) {
        var html = $(res).find('.ui.five.column.grid');

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

$(document).on('mouseenter', '.ui.custom_image_size', function() {
  var book_id = $(this).data('book-id');
  var left_offset = $(this).offset().left;
  var book_details_hover = $('#book-' + book_id + '-details-hover')

  if(left_offset + 600 > $(window).width()) {
    $(book_details_hover).css('right', '110%')
  } else {
    $(book_details_hover).css('left', '110%')
  }

  $(book_details_hover).css('visibility', 'visible')
})

$(document).on('mouseleave', '.ui.custom_image_size', function() {
  var book_id = $(this).data('book-id');
  $('#book-' + book_id + '-details-hover').css('visibility', 'hidden')
})

$(document).on('mouseenter', 'span.recommendation_tips', function() {
  $('.recommendations_popup').css('visibility', 'visible')
})

$(document).on('mouseleave', 'span.recommendation_tips', function() {
  $('.recommendations_popup').css('visibility', 'hidden')
})
