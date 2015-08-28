var request = require('request-promise'),
    Promise = require('bluebird');

function pDownloadTickerSymbolData(symbol) {
  return request(
      'https://finance-yql.media.yahoo.com/v7/finance/chart/' + symbol +
      '?period2=' + Math.floor(Date.now() / 1000) +
      '&period1=0' +
      '&interval=1d' +
      '&indicators=quote' +
      '&includeTimestamps=true' +
      '&includePrePost=true' +
      '&corsDomain=finance.yahoo.com'
  );
}

if (module.parent) {
  module.exports = pDownloadTickerSymbolData;
} else {
  pDownloadTickerSymbolData('AMRN')
  .then(console.log.bind(console))
  .done();
}
