var csv = require('csv'),
    Promise = require('bluebird');

function pTickerSymbolDataToCsv(data) {
  var rows = [];
  for (var i = 0; i < data.timestamp.length; ++i) {
    rows.push([
      data.timestamp[i],
      data.indicators.quote[0].open[i],
      data.indicators.quote[0].close[i],
      data.indicators.quote[0].high[i],
      data.indicators.quote[0].low[i],
      data.indicators.quote[0].volume[i],
    ]);
  }

  return new Promise(function(resolve, reject) {
    csv.stringify(rows, {
      header: true,
      columns: ['timestamp', 'open', 'close', 'high', 'low', 'volume'],
    }, function(err, csv) {
      if (err) return reject(err);
      resolve(csv);
    });
  });
}

if (module.parent) {
  module.exports = pTickerSymbolDataToCsv;
} else {
  var data = '';
  process.stdin.on('data', function(chunk) {
    data += chunk;
  });
  process.stdin.on('end', function() {
    data = JSON.parse(data);
    pTickerSymbolDataToCsv(data)
    .then(function(csv) {
      console.log(csv);
    })
    .done();
  });
}
