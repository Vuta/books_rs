$(document).on('turbolinks:load change', function() {
  var length = $('.fav_genres_label input[type="checkbox"]:checked').length;
  var submit_button = $('.fav_genres_submit_button input[type="submit"]');

  $(submit_button).prop('disabled', length == 0)

  if(length == 0) {
    $(submit_button).val('Select at least one genre to continue')
  } else {
    $(submit_button).val('Continue')
  }
})
