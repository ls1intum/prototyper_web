# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $('.status').each (index) ->
    refreshContainerProgress $(this).attr('app_id'), $(this).attr('container_id')
  return

@refreshContainerProgress = (app_id, container_id) ->
  $.get '/apps/' + app_id + '/containers/'+container_id+'/status', (data) ->
    $('.status').html('' + data)
  setTimeout refreshContainerProgress.bind(null, app_id, container_id), 3000

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('page:change', ready)
