// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

const readyContainers = function() {
  $('.status').each(function(index) {
    return refreshContainerProgress($(this).attr('app_id'), $(this).attr('container_id'));
  });
};

this.refreshContainerProgress = function(app_id, container_id) {
  $.get('/apps/' + app_id + '/containers/'+container_id+'/status', data => $('.status').html('' + data));
  return setTimeout(refreshContainerProgress.bind(null, app_id, container_id), 3000);
};

$(document).on('ready page:load page:change turbolinks:load', readyContainers);