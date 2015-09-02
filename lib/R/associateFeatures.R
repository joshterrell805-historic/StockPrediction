source('lib/sma.R'); 
source('lib/findBuyIndexes.R'); 
source('lib/growth.R'); 

associateFeatures = function (quotes) {
  periods        = c(5, 15, 30, 60, 120);
  quotes         = na.omit(quotes);

  buyIndexes     = findBuyIndexes(quotes, maxHoldDays=30,
      minSellToBuyRatio=1.2);
  buyTimestamps  = quotes[buyIndexes, 'timestamp'];

  quotes$should_buy = as.integer(quotes$timestamp %in% buyTimestamps);
  quotes$price      = rowMeans(subset(quotes, select=c(high, low)));
  quotes$date       = as.POSIXlt(quotes$timestamp, origin="1970-01-01");

  for (period in periods) {
    quotes[,paste('sma', period, sep='_')] = sma(quotes, 'price', period);
    quotes[,paste('vma', period, sep='_')] = sma(quotes, 'volume', period);
  }

  # everything below this point is a feature for use in the neuralnet
  quotes$wday = quotes$date$wday;
  quotes$mday = quotes$date$mday;
  quotes$yday = quotes$date$yday;

  # growth of (s|v)ma 30 from 30... 30, 60, and 90 ago
  for (p in c(30, 60, 90)) {
    for (m in c('sma', 'vma')) {
      name = paste(m, 'growth', '30', p, sep='_');
      quotes[,name] = growth(quotes, paste(m, 30, sep='_'), p);
    }
  }
  # growth of 60.. 60 ago
  for (p in c(60)) {
    for (m in c('sma', 'vma')) {
      name = paste(m, 'growth', '60', p, sep='_');
      quotes[,name] = growth(quotes, paste(m, 60, sep='_'), p);
    }
  }
  # growth of 15...
  for (p in c(15, 30, 45)) {
    for (m in c('sma', 'vma')) {
      name = paste(m, 'growth', '15', p, sep='_');
      quotes[,name] = growth(quotes, paste(m, 15, sep='_'), p);
    }
  }
  # growth of 5...
  for (p in c(5, 10, 15)) {
    for (m in c('sma', 'vma')) {
      name = paste(m, 'growth', '5', p, sep='_');
      quotes[,name] = growth(quotes, paste(m, 5, sep='_'), p);
    }
  }

  na.omit(quotes);
}
