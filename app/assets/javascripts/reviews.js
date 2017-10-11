// $(document).on('turbolinks:load', function(){
//   var counter = 1;

//   $('a.genre_link').click(function() {
//     var fav_content = $('.fav_content');
//     var fav_content_length = fav_content.length;

//     for(var i = 0; i < fav_content_length; i++) {
//       $(fav_content[i]).removeClass('fav_content_visible');
//     }

//     var links = $('a.genre_link');

//     for(var i = 0; i < links.length; i++) {
//       $(links[i]).removeClass('active');
//     }

//     var genre = $(this).data('genre');
//     $('.' + genre + '.fav_content').addClass('fav_content_visible');
//     $(this).addClass('active');

//     // counter = 0;
//     $('a.load_more_books').click();
//   })

//   // $('a.load_more_books').click(function() {
//   //   counter += 1;
//   //   $.get('/rate_books?page=' + counter, function(data, status) {
//   //     console.log(data)
//   //   })
//   // })

//   $('a.load_more_books').click(function() {
//     var genre = $('a.genre_link.active').data('genre');
//     counter += 1;
//     $('.' + genre + ' div .books_content').slice(0, 50 * counter).addClass('books_content_visible');
//   });

//   $('a.genre_link.default_fav_content').click();
// })
