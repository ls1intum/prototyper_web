# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $('.pop').on 'click', ->
    img = $(this).find('img')
    width = img.get(0).clientWidth * 7.3
    $('.imagepreview').attr 'src', img.attr('src')
    $('#imagemodal .modal-dialog').css 'width', width
    $('#imagemodal').modal 'show'
    false
  return

$(document).ready ready
$(document).on 'page:change', ready
