// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

const readyReleases = function() {
  $('select').selectpicker();
  $('#beta_bamboo_branch').change(function() {
    getBranchBuilds($(this).val());
  });
};

this.getBranchBuilds = function(branch_key) {
  const url = location.protocol + '//' + location.host + '/bamboo_builds?branch=' + branch_key;
  return $.get(url, function(data) {
    $('#beta_build_key').replaceWith('' + data);
    $('[data-id=beta_build_key]').remove();
    $('#beta_build_key').selectpicker();
  });
};

$(document).on('ready page:load page:change turbolinks:load', readyReleases);