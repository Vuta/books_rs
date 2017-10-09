$(document).ready(function(){
  $('a.genre_link').click(function() {
    var fav_content = $('.fav_content');
    var fav_content_length = fav_content.length;

    for(var i = 0; i < fav_content_length; i++) {
      $(fav_content[i]).removeClass('fav_content_visible');
    }

    var links = $('a.genre_link');

    for(var i = 0; i < links.length; i++) {
      $(links[i]).removeClass('active');
    }

    var genre = $(this).data('genre');
    $('.' + genre + '.fav_content').addClass('fav_content_visible');
    $(this).addClass('active');
  })

  $('a.genre_link.default_fav_content').click();
})
