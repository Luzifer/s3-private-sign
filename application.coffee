awsKey = null
awsSecret = null
generated_tag = null
create_lock = false

loadOptions = () ->
  chrome.storage.local.get 'AWSAccessKey', (data) ->
    awsKey = data.AWSAccessKey
  chrome.storage.local.get 'AWSAccessSecret', (data) ->
    awsSecret = data.AWSAccessSecret

$ ->
  loadOptions()
  $(document).bind 'DOMSubtreeModified', () ->
    if $('table', '#properties-panel-properties').length > 0 and $('#properties-panel-property-signed-url').length < 1
      addUIElements()
    if $('#properties-panel-property-signed-url').length == 1 and $('#properties-panel-property-url').is(':visible')
      $('#properties-panel-property-signed-url').show()
    if $('.properties-panel-property-value', '#properties-panel-property-etag').text() != generated_tag and generated_tag != null
      addUIElements()
      generated_tag = null
  $('#properties-panel-property-url').bind 'change', addUIElements()

delayed = (time, fkt) ->
  window.setTimeout fkt, time

generateSignedURL = () ->
  lnk = $('<a>')
  
  origin_link = $('.properties-panel-property-value a', '#properties-panel-property-url').attr 'href'
  resource = '/' + origin_link.split('/').slice(3).join('/')
  prefix = origin_link.split('/').slice(0, 3).join('/')

  expiry = generateExpiry($(this).data('seconds'))
  sign_src = "GET\n\n\n#{expiry}\n#{resource}"
  signature = CryptoJS.enc.Base64.stringify CryptoJS.HmacSHA1(sign_src, awsSecret)
  url_sig = encodeURIComponent signature

  url = "#{prefix}#{resource}?Expires=#{expiry}&AWSAccessKeyId=#{awsKey}&Signature=#{url_sig}"
  lnk.attr
    href: url
  lnk.text url

  $(this).parent().empty().append lnk
  generated_tag = $('.properties-panel-property-value', '#properties-panel-property-etag').text()

generateExpiry = (ttl = 86400) ->
  dateObj = new Date
  now = dateObj.getTime()
  parseInt(now / 1000) + ttl

addUIElements = () ->
  if create_lock
    return
  create_lock = true
  $('#properties-panel-property-signed-url').remove()
  ne = $('<tr>')
  ne.attr
    id: 'properties-panel-property-signed-url'

  name = $('<td>')
  name.addClass 'properties-panel-property-name'
  name.text 'Signed URL:'
  name.appendTo ne

  value = $('<td>')
  value.addClass 'properties-panel-property-value'
  value.append('Expiry: ')

  for duration, seconds of { '1h': 3600, '1d': 86400, '1w': 604800, '1m': 2592000, '1a': 31536000 }
    link = $('<a>')
    link.attr
      href: 'javascript:void(0)'
    link.text "#{duration}"
    link.data
      seconds: seconds
    link.bind 'click', generateSignedURL
    link.appendTo value
    value.append(' ')

  value.appendTo ne
  ne.appendTo $('table', '#properties-panel-properties')
  create_lock = false

