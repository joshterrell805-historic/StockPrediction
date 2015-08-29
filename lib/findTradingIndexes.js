/**
 * Return an array of arrays. Each sub array represents a pair of trading
 * indexes in `data`. The first index is the buy index, and the second
 * is the sell index.
 *
 * Constraints:
 *  the sell index must occur after the buy index by no more than
 *    `options.maxHoldDays`.
 *  the sell day's price must be greater than the buy day's price by at least
 *    `options.minGrowthPercent`.
 */
function findTradingIndexes(data, options) {
  var options = _.defaults({}, options, options, {
    // max days to hold the stock, or days between buy and sell
    maxHoldDays: 20,
    // a growth of 0.5 means the sell price must be 50% greater than buy.x
    minGrowthPercent: 0.5,
    // We have a high and low price for every every day.
    // By default, look to buy at the high of the day and sell at the low
    // of the day (worst-case scenario)
    buyValue: 'high',
    sellValue: 'low',
  });

  var buyValues = data.indicators.quote[0][options.buyValue];
  var sellValues = data.indicators.quote[0][options.sellValue];
  var tradingIndexes = [];

  for (var i = 0; i < buyValues.length; ++i) {
    var buy = buyValues[i];
    if (buy === null) continue;
    for (var j = i + 1; j < sellValues.length && j - i <= options.maxHoldDays;
        ++j) {
      var sell = sellValues[j];
      if (sell === null) continue;
      if (sell >= buy * (1 + options.minGrowthPercent)) {
        tradingIndexes.push([i, j]);
      }
    }
  }

  return tradingIndexes;
}

if (module.parent) {
  module.exports = findTradingIndexes;
} else {
  var _ = require('lodash');
  require('./pDownloadTickerSymbolData')('AMRN')
  .then(function(data) {
    var indexes = findTradingIndexes(data, {
      maxHoldDays: 5,
      minGrowthPercent: 1.0,
    });
    var trades = _.map(indexes, function(pair) {
      return {
        buy: {
          timestamp: data.timestamp[pair[0]],
          price: data.indicators.quote[0].low[pair[0]],
        },
        sell: {
          timestamp: data.timestamp[pair[1]],
          price: data.indicators.quote[0].high[pair[1]],
        }
      };
    });

    var util = require('util');
    var output = util.inspect(indexes, {colors: true, depth: null});
    console.log(output);

    var output = util.inspect(trades, {colors: true, depth: null});
    console.log(output);
  })
  .done();
}