x = require('casper').selectXPath
casper = require('casper').create()

# casper.start 'https://id.heroku.com/login', ->
#   @fill 'form', {
#     'input[name="email"]': 'karim@omts.fr'
#     'input[name="password"]': 'sicsercyimavdownigs9'
#   }, true
#   @echo 'fill OK'
#   return

# casper.echo 'Connected to Heroku !'
# casper.start 'https://id.heroku.com/login'
# casper.wait(5000)
casper.start 'http://id.heroku.com/login', ->
  @fill '#login form', {
    'email': 'iman@omts.fr'
    'password': 'omtsfuckyeah'
  }, true
  @echo 'OK'
  return

# casper.wait(2000)
# casper.then ->
#   @click x('//*[@id="login"]/form/button')
#   @echo 'Sending Form..'
#   return

casper.waitForUrl 'https://dashboard.heroku.com/', ->
  @echo 'Connected to Dashboard !'
  return

# casper.then ->
#   link = 'https://dashboard.heroku.com/invoices/2015/8'
#   @open link
#   return

casper.waitForUrl 'https://dashboard.heroku.com/invoices/2015/8', ->
  @echo 'Connected to Invoice page'
  @capture 'heroku.png', {
    top: 500,
    left: 500,
    width: 0,
    height: 0
  }
  return

casper.run ->
  @echo('Ended.').exit()
  return
