var csv = require('csv'),
    Promise = require('bluebird');

function pTradingIndexesToCsv(data) {
  return new Promise(function(resolve, reject) {
    csv.stringify(data, {
      header: true,
      columns: ['buy_index', 'sell_index'],
    }, function(err, csv) {
      if (err) return reject(err);
      resolve(csv);
    });
  });
}


if (module.parent) {
  module.exports = pTradingIndexesToCsv;
} else {
  var data = '';
  process.stdin.on('data', function(chunk) {
    data += chunk;
  });
  process.stdin.on('end', function() {
    data = JSON.parse(data);
    pTradingIndexesToCsv(data)
    .then(function(csv) {
      console.log(csv);
    })
    .done();
  });
}
