
/**
 * Returns a bare object of the URL's query parameters.
 * You can pass just a query string rather than a complete URL.
 * The default URL is the current page.
 */
function getUrlParams (url) {
    // http://stackoverflow.com/a/23946023/2407309
    if (typeof url == 'undefined') {
        url = window.location.search
    }
    var url = url.split('#')[0] // Discard fragment identifier.
    var queryString = url.split('?')[1]
    if (!queryString) {
        if (url.search('=') !== false) {
            queryString = url
        }
    }
    var urlParams = {}
    if (queryString) {
        var keyValuePairs = queryString.split('&')
        for (var i = 0; i < keyValuePairs.length; i++) {
            var keyValuePair = keyValuePairs[i].split('=')
            var paramName = keyValuePair[0]
            var paramValue = keyValuePair[1] || ''
            urlParams[paramName] = decodeURIComponent(paramValue.replace(/\+/g, ' '))
        }
    }
    return urlParams
} // getUrlParams


function download(url, cb) {
  var data = "";
  var request = require("http").get(url, function(res) {

    res.on('data', function(chunk) {
      data += chunk;
    });

    res.on('end', function() {
      cb(data);
    })
  });

  request.on('error', function(e) {
    console.log("Got error: " + e.message);
  });
}

var x = require('casper').selectXPath;
var casper = require('casper').create();
casper.options.waitTimeout = 15000;
casper.start('https://id.orange.fr/auth_user/bin/auth_user.cgi?return_url=http://www.orange.fr/');
casper.echo('Connected to Orange !');
casper.waitForUrl('https://id.orange.fr/auth_user/bin/auth_user.cgi?return_url=http://www.orange.fr/', function() {
  casper.then(function() {
    this.fill('form#AuthentForm', {
      'credential':    '0614024562',
      'password':    'omtsfuckyeah7'
    }, true);
    this.echo('Fill OK !');
  });
});
// Connect To Account


casper.then(function() {
  this.click(x("//*[@id='AuthentForm']/div[7]/table/tbody/tr/td/table/tbody/tr/td/div/input"));
  this.echo('Sending Form..');
});

casper.waitForUrl('http://www.orange.fr/portail', function() {
  this.echo('Connected and redirected to Portail !');
});

// Retrieve Contracts
casper.then(function() {
  link = 'https://m.espaceclientv3.orange.fr/?cont=ECO';
  this.open(link);
})

casper.waitForUrl('https://m.espaceclientv3.orange.fr/?cont=ECO', function() {
  this.echo('In espace client right now!');
});

casper.then(function() {
  contracts = [];
  contracts = this.evaluate(function() {
    return [].map.call(document.querySelectorAll('a.lienConso'), function(l) {
      return l.getAttribute('href');
    });
  });
  // Get contracts numbers
  contract_number = [];
  this.eachThen(contracts, function(r) {
    contract_number = getUrlParams(r.data)['contract'];
    this.echo("Contract n° : " + contract_number);
    //Retrieve bills
    this.open('https://m.espaceclientv3.orange.fr/?page=facture-telecharger&idContrat='+contract_number+'&idFacture=1.pdf');
    this.wait(2*1000);
    this.on('page.resource.received', function(resource) {
     if (resource.contentType && resource.stage === 'end' && resource.contentType.indexOf('application/pdf') > -1)  {
          var d = new Date();
          var n = "0" + d.getMonth();
          var y = d.getFullYear();
          this.echo(resource);
          this.echo(resource.url);
          this.download(resource.url, +y+'/'+n+'/facture-'+contract_number+'.pdf');
        }
      });
    });
});

casper.run(function() {
    this.echo('Ended.').exit();
});
