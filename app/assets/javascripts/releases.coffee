# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $('select').selectpicker()
  $('#beta_bamboo_branch').change ->
    getBranchBuilds($(this).val())
    return
  return

@getBranchBuilds = (branch_key) ->
  url = location.protocol + '//' + location.host + '/bamboo_builds?branch=' + branch_key
  $.get url, (data) ->
    $('#beta_build_key').replaceWith '' + data
    $('[data-id=beta_build_key]').remove()
    $('#beta_build_key').selectpicker()
    return

$(document).ready(ready)
$(document).on('page:load', ready)
