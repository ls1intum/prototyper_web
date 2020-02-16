// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

const readyFeedbacks = function() {
  $('.pop').on('click', function() {
    const img = $(this).find('img');
    const width = img.get(0).clientWidth * 7.3;
    $('.imagepreview').attr('src', img.attr('src'));
    $('#imagemodal .modal-dialog').css('width', width);
    $('#imagemodal').modal('show');
    return false;
  });
};

$(document).on('ready page:load page:change turbolinks:load', readyFeedbacks);