$ ->
  $('#access_key').val localStorage['AWSAccessKey']
  $('#secret_key').val localStorage['AWSAccessSecret']

  $('#save').bind 'click', saveOptions

delayed = (time, fkt) ->
  window.setTimeout fkt, time

loadOptions = () ->
  chrome.storage.local.get 'AWSAccessKey', (data) ->
    $('#access_key').val data.AWSAccessKey
  chrome.storage.local.get 'AWSAccessSecret', (data) ->
    $('#secret_key').val data.AWSAccessSecret

saveOptions = () ->
  chrome.storage.local.set
    'AWSAccessKey': $('#access_key').val()
    'AWSAccessSecret': $('#secret_key').val()
  $('#status').text('Saved.')
  delayed 750, ->
    $('#status').text('')
