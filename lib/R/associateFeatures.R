source('lib/sma.R'); 
source('lib/findBuyIndexes.R'); 
source('lib/growth.R'); 

associateFeatures = function (quotes) {
  periods        = c(2, 4, 8, 16, 32);
  quotes         = na.omit(quotes);

  buyIndexes     = findBuyIndexes(quotes, maxHoldDays=7,
      minSellToBuyRatio=1.08);
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

  # growth of 2 from c(...) days ago
  for (p in c(2, 4, 6, 8, 10, 12, 14)) {
    for (m in c('sma', 'vma')) {
      name = paste(m, 'growth', '2', p, sep='_');
      quotes[,name] = growth(quotes, paste(m, '2', sep='_'), p);
    }
  }
  for (p in c(4, 8, 16)) {
    for (m in c('sma', 'vma')) {
      name = paste(m, 'growth', '4', p, sep='_');
      quotes[,name] = growth(quotes, paste(m, '4', sep='_'), p);
    }
  }
  for (p in c(8, 16, 24)) {
    for (m in c('sma', 'vma')) {
      name = paste(m, 'growth', '8', p, sep='_');
      quotes[,name] = growth(quotes, paste(m, '8', sep='_'), p);
    }
  }
  for (p in c(16)) {
    for (m in c('sma', 'vma')) {
      name = paste(m, 'growth', '16', p, sep='_');
      quotes[,name] = growth(quotes, paste(m, '16', sep='_'), p);
    }
  }

  na.omit(quotes);
}
