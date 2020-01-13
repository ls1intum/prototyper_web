# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@refreshReleaseProgress = (app_id, release_id) ->
  $.get '/apps/' + app_id + '/releases/' + release_id + '/status', (data) ->
    $('#release_row-'+release_id).find('.status').html('' + data)
  setTimeout refreshReleaseProgress.bind(null, app_id, release_id), 3000

ready = ->
  $('select').selectpicker()
  $('#app_bamboo_project').change ->
    getProjectPlans($(this).val())
    return
  $('.prototype_row').each (index) ->
    refreshReleaseProgress $(this).attr('app_id'), $(this).attr('release_id')
    return
  $('.new_release_table').on 'click', '.clickable-row', (event) ->
    $('.new_release_table').find('.clickable-row').removeClass 'active'
    $(this).addClass('active')
    $('#show_release_submission_button').prop("disabled", false);
    return
  $('#new_release_modal').on 'show.bs.modal', (event) ->
    button = $(event.relatedTarget)
    recipient = button.data('group')
    modal = $(this)
    modal.find('#release_email_checkbox_text').text 'Send email to all members in the release group ' + recipient
    modal.find('#release_submission_button').text 'Release to ' + recipient
    modal.find('#release_submission_button').data('group_id', button.data('group_id'))
    modal.find('#release_submission_button').data('is_main_release', button.data('is_main_release'))
    modal.find('#remove_release_button').data('group_id', button.data('group_id'))
    modal.find('#remove_release_button').data('is_main_release', button.data('is_main_release'))
    return
  $('#content-nav>.tab-pane').filter((idx, element) ->
    if window.location.hash == null
      return false
    if element.id == window.location.hash.substr(1)
      $('#content-nav>.tab-pane.active').removeClass 'active in'
      return true
    false
  ).addClass('active').addClass 'in'
  $('.content-nav').find('a[data-toggle=\'tab\']').filter((idx, element) ->
    if window.location.hash == null
      return false
    if element.getAttribute('href') == window.location.hash
      $('.content-nav').find('a[data-toggle=\'tab\']').parent().removeClass 'active'
      return true
    false
  ).parent().addClass 'active'
  return

@getProjectPlans = (project_key) ->
  url = location.protocol + '//' + location.host + '/bamboo_plans?project=' + project_key
  $.get url, (data) ->
    $('#app_bamboo_plan').replaceWith '' + data
    $('[data-id=app_bamboo_plan]').remove()
    $('#app_bamboo_plan').selectpicker()
    return

@showReleaseSubmissionDialog = (app_id) ->
  $('#release_selection').fadeOut 'normal', ->
    $('#release_submission').fadeIn 'normal'
    selected_release_id = $('#release_selection').find('tr.active').attr('release_id')
    $('#release_submission').find('tr[release_id=' + selected_release_id + ']').show()
    $('#release_submission').find('tr[release_id=' + selected_release_id + ']').addClass 'active'
    $('#release_submission').find('tr').hide()
    $('#release_submission').find('tr[release_id=' + selected_release_id + ']').show()
    $('#release_submission').find('#release_submission_button').data('release_id', selected_release_id)

    fillInReleaseNotes(app_id, selected_release_id)
    return

@resetNewReleaseDialog = ->
  $('.clickable-row').removeClass 'active'
  $('#show_release_submission_button').prop("disabled", true);
  $('#release_submission').hide()
  $('#release_selection').show()

@fillInReleaseNotes = (app_id, release_id) ->
  $.get '/apps/' + app_id + '/releases/' + release_id + '/release_notes', (data) ->
    $('#release_submission').find('textarea').html('' + data)

@releaseToGroup = (app_id, release_id, group_id, is_main_release, button) ->
  $(button).prop("disabled", true)
  changelog = $('#release_submission').find('textarea').val()
  send_mails = $('#release_submission').find('#send_mails').get(0).checked
  $.post('/apps/' + app_id + '/releases/' + release_id + '/release_to_group', {
    group_id: group_id,
    'is_main_release': is_main_release,
    'send_mails': send_mails,
    'changelog': changelog
  }, (data) ->
    $('#new_release_modal').modal 'hide'
    window.location.hash = ''
    window.location.reload false
    return
  ).fail (data) ->
    alert data.responseText
    return

@removeReleaseFromGroup = (app_id, group_id, is_main_release, button) ->
  $(button).prop("disabled", true)
  $.post('/apps/' + app_id + '/remove_release_from_group', {
    group_id: group_id,
    'is_main_release': is_main_release
  }, (data) ->
    window.location.hash = ''
    window.location.reload false
    return
  ).fail (data) ->
    alert data.responseText
    return

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on 'page:change', ready
