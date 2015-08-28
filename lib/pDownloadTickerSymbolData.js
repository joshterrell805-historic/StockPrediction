var request = require('request-promise'),
    Promise = require('bluebird'),
    _ = require('lodash');

function pDownloadTickerSymbolData(symbol, options) {
  _.defaults(options, options, {
    start: 0,
    end: Math.floor(Date.now() / 1000),
  })
  return request(
      'https://finance-yql.media.yahoo.com/v7/finance/chart/' + symbol +
      '?period2=' + options.end +
      '&period1=' + options.start +
      '&interval=1d' +
      '&indicators=quote' +
      '&includeTimestamps=true' +
      '&includePrePost=true' +
      '&corsDomain=finance.yahoo.com'
  )
  .then(JSON.parse)
  .then(function(obj) {
    return obj.chart.result[0];
  });
}

if (module.parent) {
  module.exports = pDownloadTickerSymbolData;
} else {
  pDownloadTickerSymbolData(process.argv[2] || 'AMRN', {
    start: process.argv[3] ?
        Math.floor(Date.now() / 1000) - parseInt(process.argv[3])*24*60*60 :
        undefined,
  })
  .then(function(output) {
    var util = require('util');
    console.log(util.inspect(output, {colors: true, depth: null}));
  })
  .done();
}
