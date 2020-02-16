// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

this.refreshReleaseProgress = function(app_id, release_id) {
  $.get('/apps/' + app_id + '/releases/' + release_id + '/status', data => $('#release_row-'+release_id).find('.status').html('' + data));
  return setTimeout(refreshReleaseProgress.bind(null, app_id, release_id), 3000);
};

const readyApps = function() {
  $('select').selectpicker();
  $('#app_bamboo_project').change(function() {
    getProjectPlans($(this).val());
  });
  $('.prototype_row').each(function(index) {
    refreshReleaseProgress($(this).attr('app_id'), $(this).attr('release_id'));
  });
  $('.new_release_table').on('click', '.clickable-row', function(event) {
    $('.new_release_table').find('.clickable-row').removeClass('active');
    $(this).addClass('active');
    $('#show_release_submission_button').prop("disabled", false);
  });
  $('#new_release_modal').on('show.bs.modal', function(event) {
    const button = $(event.relatedTarget);
    const recipient = button.data('group');
    const modal = $(this);
    modal.find('#release_email_checkbox_text').text('Send email to all members in the release group ' + recipient);
    modal.find('#release_submission_button').text('Release to ' + recipient);
    modal.find('#release_submission_button').data('group_id', button.data('group_id'));
    modal.find('#release_submission_button').data('is_main_release', button.data('is_main_release'));
    modal.find('#remove_release_button').data('group_id', button.data('group_id'));
    modal.find('#remove_release_button').data('is_main_release', button.data('is_main_release'));
  });
  $('#content-nav>.tab-pane').filter(function(idx, element) {
    if (window.location.hash === null) {
      return false;
    }
    if (element.id === window.location.hash.substr(1)) {
      $('#content-nav>.tab-pane.active').removeClass('active in');
      return true;
    }
    return false;
  }).addClass('active').addClass('in');
  $('.content-nav').find('a[data-toggle=\'tab\']').filter(function(idx, element) {
    if (window.location.hash === null) {
      return false;
    }
    if (element.getAttribute('href') === window.location.hash) {
      $('.content-nav').find('a[data-toggle=\'tab\']').parent().removeClass('active');
      return true;
    }
    return false;
  }).parent().addClass('active');
};

this.getProjectPlans = function(project_key) {
  const url = location.protocol + '//' + location.host + '/bamboo_plans?project=' + project_key;
  return $.get(url, function(data) {
    $('#app_bamboo_plan').replaceWith('' + data);
    $('[data-id=app_bamboo_plan]').remove();
    $('#app_bamboo_plan').selectpicker();
  });
};

this.showReleaseSubmissionDialog = app_id => $('#release_selection').fadeOut('normal', function() {
  $('#release_submission').fadeIn('normal');
  const selected_release_id = $('#release_selection').find('tr.active').attr('release_id');
  $('#release_submission').find('tr[release_id=' + selected_release_id + ']').show();
  $('#release_submission').find('tr[release_id=' + selected_release_id + ']').addClass('active');
  $('#release_submission').find('tr').hide();
  $('#release_submission').find('tr[release_id=' + selected_release_id + ']').show();
  $('#release_submission').find('#release_submission_button').data('release_id', selected_release_id);

  fillInReleaseNotes(app_id, selected_release_id);
});

this.resetNewReleaseDialog = function() {
  $('.clickable-row').removeClass('active');
  $('#show_release_submission_button').prop("disabled", true);
  $('#release_submission').hide();
  return $('#release_selection').show();
};

this.fillInReleaseNotes = (app_id, release_id) => $.get('/apps/' + app_id + '/releases/' + release_id + '/release_notes', data => $('#release_submission').find('textarea').html('' + data));

this.releaseToGroup = function(app_id, release_id, group_id, is_main_release, button) {
  $(button).prop("disabled", true);
  const changelog = $('#release_submission').find('textarea').val();
  const send_mails = $('#release_submission').find('#send_mails').get(0).checked;
  return $.post('/apps/' + app_id + '/releases/' + release_id + '/release_to_group', {
    group_id,
    'is_main_release': is_main_release,
    'send_mails': send_mails,
    'changelog': changelog
  }, function(data) {
    $('#new_release_modal').modal('hide');
    window.location.hash = '';
    window.location.reload(false);
  }).fail(function(data) {
    alert(data.responseText);
  });
};

this.removeReleaseFromGroup = function(app_id, group_id, is_main_release, button) {
  $(button).prop("disabled", true);
  return $.post('/apps/' + app_id + '/remove_release_from_group', {
    group_id,
    'is_main_release': is_main_release
  }, function(data) {
    window.location.hash = '';
    window.location.reload(false);
  }).fail(function(data) {
    alert(data.responseText);
  });
};


$(document).on('ready page:load page:change turbolinks:load', readyApps);