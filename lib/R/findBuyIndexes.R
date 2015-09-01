# Find all the buy-sell pairs in the dataset where
#   maxHoldDays: maxiumum days between buy and sell dates
#   minSellToBuyRatio: minimum ratio of buy to sell. 2 is a 100% profit
#   buyValue: the day's price to buy at. Either ('price', *'high'*, or 'low')
#   sellValue: the day's price to sell at. Either ('price', 'high', or *'low'*)
#   filterMaxSellPoints: filter consecutive buy days to day(s) with max sell
#                        days?

findBuyIndexes = function(quotes, maxHoldDays=30, minSellToBuyRatio=2.0,
    buyValue='high', sellValue='low', minConsecutiveSellDays=5,
    filterMaxSellPoints=T) {

  m = nrow(quotes);
  buyValues  = quotes[,buyValue];
  sellValues = quotes[,sellValue];

  buyIndexes = c();
  sellDays = c();

  sapply(1:m, function(i) {
    buyIndex = NA;
    sellDaysIndex = NA;
    sapply(i:(i+maxHoldDays), function(j) {
      if (j == i) {
        buyIndex <<- NA;
      }
      if (j < m) {
        if (buyValues[i] * minSellToBuyRatio <= sellValues[j]) {
          if (is.na(buyIndex)) {
            buyIndex <<- i;
            sellDaysIndex <<- 0;
          }
          sellDaysIndex <<- sellDaysIndex + 1;
        }
      }
    });
    if (!is.na(buyIndex) && sellDaysIndex >= minConsecutiveSellDays) {
      buyIndexes <<- append(buyIndexes, buyIndex);
      sellDays <<- append(sellDays, sellDaysIndex);
    }
  });

  stopifnot(length(sellDays) == length(buyIndexes));

  buyIndexesFiltered = c();
  if (filterMaxSellPoints && length(buyIndexes) >= 2) {
    maxSellDays = 0;
    buyDayIndexes = c();
    sapply(1:length(buyIndexes), function(i) {
      if (i == 1 || (buyIndexes[i-1] + 1) != buyIndexes[i]) {
        if (i != 1) {
          buyIndexesFiltered <<- append(buyIndexesFiltered, buyDayIndexes);
        }
        maxSellDays <<- sellDays[i];
        buyDayIndexes <<- c(buyIndexes[i]);
      } else {
        if (sellDays[i] > maxSellDays) {
          maxSellDays <<- sellDays[i];
          buyDayIndexes <<- c(buyIndexes[i]);
        } else if (sellDays[i] == maxSellDays) {
          buyDayIndexes <<- append(buyDayIndexes, buyIndexes[i]);
        }
      }
    });
    buyIndexesFiltered <<- append(buyIndexesFiltered, buyDayIndexes);
  } else {
    buyIndexesFiltered <<- buyIndexes;
  }

  buyIndexesFiltered;
}
