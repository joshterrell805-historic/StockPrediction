# Find all the buy-sell pairs in the dataset where
#   maxHoldDays: maxiumum days between buy and sell dates
#   minSellToBuyRatio: minimum ratio of buy to sell. 2 is a 100% profit
#   buyValue: the day's price to buy at. Either ('price', *'high'*, or 'low')
#   sellValue: the day's price to sell at. Either ('price', 'high', or *'low'*)

findBuyIndexes = function(quotes, maxHoldDays=30, minSellToBuyRatio=2.0,
    buyValue='high', sellValue='low') {

  m = nrow(quotes);
  buyValues  = quotes[,buyValue];
  sellValues = quotes[,sellValue];

  buyIndexes = c();

  sapply(1:m, function(i) {
    sapply(i:(i+maxHoldDays), function(j) {
      if (j < m) {
        if (buyValues[i] * minSellToBuyRatio <= sellValues[j]) {
          if (!(i  %in% buyIndexes)) {
            buyIndexes <<- append(buyIndexes, i);
          }
        }
      }
    });
  });

  return(buyIndexes);
}
