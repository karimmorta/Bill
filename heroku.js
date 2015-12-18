var x = require('casper').selectXPath;
var casper = require('casper').create();


casper.start('https://id.heroku.com/login');
casper.then(function() {
  this.fill('form', {
    'email':    'karim@omts.fr',
    'password':    'sicsercyimavdownigs9'
  }, true);
  this.echo('Fill OK !');
});