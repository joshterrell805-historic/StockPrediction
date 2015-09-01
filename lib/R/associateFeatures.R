source('lib/sma.R'); 
source('lib/findBuyIndexes.R'); 
source('lib/growth.R'); 

associateFeatures = function (quotes) {
  periods = c(15, 60);
  quotes         = na.omit(quotes);

  buyIndexes     = findBuyIndexes(quotes, maxHoldDays=30,
      minSellToBuyRatio=1.2);
  buyTimestamps  = quotes[buyIndexes, 'timestamp'];

  quotes$should_buy = as.integer(quotes$timestamp %in% buyTimestamps);
  quotes$price      = rowMeans(subset(quotes, select=c(high, low)));
  quotes$date       = as.Date(as.POSIXct(quotes$timestamp,
      origin="1970-01-01"));


  for (period in periods) {
    quotes[,paste('sma', period, sep='_')] = sma(quotes, 'price', period);
    quotes[,paste('vma', period, sep='_')] = sma(quotes, 'volume', period);
  }

  for (p in c(15, 30, 45)) {
    for (m in c('sma', 'vma')) {
      name = paste(m, 'growth', '15', p, sep='_');
      quotes[,name] =
          growth(quotes, paste(m, '15', sep='_'), p);
    }
  }

  na.omit(quotes);
}
