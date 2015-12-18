# ip_server = 'localhost:8585'

x = require('casper').selectXPath
casper = require('casper').create()

getUrlParams = (url) ->
  if typeof url == 'undefined'
    url = window.location.search
  url = url.split('#')[0]
  # Discard fragment identifier.
  queryString = url.split('?')[1]
  if !queryString
    if url.search('=') != false
      queryString = url
  urlParams = {}
  if queryString
    keyValuePairs = queryString.split('&')
    i = 0
    while i < keyValuePairs.length
      keyValuePair = keyValuePairs[i].split('=')
      paramName = keyValuePair[0]
      paramValue = keyValuePair[1] or ''
      urlParams[paramName] = decodeURIComponent(paramValue.replace(/\+/g, ' '))
      i++
  urlParams

# getUrlParams

download = (url, cb) ->
  data = ''
  request = require('http').get(url, (res) ->
    res.on 'data', (chunk) ->
      data += chunk
      return
    res.on 'end', ->
      cb data
      return
    return
  )
  request.on 'error', (e) ->
    console.log 'Got error: ' + e.message
    return
  return

# start web server
# var service = server.listen(ip_server, function(request, response) {
# service = casper.listen(ip_server, (request, response) ->

  casper.start 'https://id.orange.fr/auth_user/bin/auth_user.cgi'
  casper.echo 'Connected to Orange !'
  # Connect To Account
  casper.then ->
    @fill 'AuthentForm', {
      'credential': '0614024562'
      'password': 'omtsfuckyeah7'
    }, true
    @echo 'Fill OK !'
    return
  casper.then ->
    @click x("//*[@id=\'AuthentForm\']/div[7]/table/tbody/tr/td/table/tbody/tr/td/div/input")
    @echo 'Sending Form..'
    return
  casper.waitForUrl 'http://www.orange.fr/portail', ->
    @echo 'Connected and redirected to Portail !'
    return
  # Retrieve Contracts
  casper.then ->
    link = 'https://m.espaceclientv3.orange.fr/?cont=ECO'
    @open link
    return
  casper.waitForUrl 'https://m.espaceclientv3.orange.fr/?cont=ECO', ->
    @echo 'In espace client right now!'
    return
  casper.then ->
    contracts = []
    contracts = @evaluate(->
      [].map.call document.querySelectorAll('a.lienConso'), (l) ->
        l.getAttribute 'href'
    )
    # Get contracts numbers
    contract_number = []
    @eachThen contracts, (r) ->
      contract_number = getUrlParams(r.data)['contract']
      @echo 'Contract n° : ' + contract_number
      #Retrieve bills
      @open 'https://m.espaceclientv3.orange.fr/?page=facture-telecharger&idContrat=' + contract_number + '&idFacture=1.pdf'
      @wait 2 * 1000
      @on 'page.resource.received', (resource) ->
        if resource.contentType and resource.stage == 'end' and resource.contentType.indexOf('application/pdf') > -1
          d = new Date
          n = '0' + d.getMonth()
          y = d.getFullYear()
          @echo resource
          @echo resource.url
          @download resource.url, +y + '/' + n + '/facture-' + contract_number + '.pdf'
        return
      return
    return
  casper.run ->
    @echo('Ended.').exit()
  return
  # return
# console.log('Server running at http://' + ip_server+'/')
