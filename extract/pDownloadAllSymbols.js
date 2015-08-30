var fs = require('fs'),
    Promise = require('bluebird'),
    _ = require('lodash');

var pDownloadTickerSymbolData = require('./pDownloadTickerSymbolData'),
    pTickerSymbolDataToCsv = require('../transform/pTickerSymbolDataToCsv'),
    pReadFile = Promise.promisify(fs.readFile),
    pWriteFile = Promise.promisify(fs.writeFile);

pReadFile('data/symbols.csv')
.then(function(symbols) {
  return symbols.toString().trim().split(',');
})
.then(function(symbols) {
  return Promise.all(
    _.map(symbols, function(symbol) {
      return pDownloadTickerSymbolData(symbol)
      .then(pTickerSymbolDataToCsv)
      .then(function(csv) {
        return pWriteFile('data/' + symbol + '.csv', csv);
      });
    })
  );
})
.done();
