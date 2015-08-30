source('lib/sma.R'); 
source('lib/findBuyIndexes.R'); 
library(neuralnet);

quotes         = read.csv('data/CJES.csv');
quotes         = na.omit(quotes);
buyIndexes     = findBuyIndexes(quotes, maxHoldDays=30, minSellToBuyRatio=1.30);
buyTimestamps  = quotes[buyIndexes, 'timestamp'];

quotes$should_buy = as.integer(quotes$timestamp %in% buyTimestamps);
quotes$price      = rowMeans(subset(quotes, select=c(high, low)));
quotes$date       = as.Date(as.POSIXct(quotes$timestamp, origin="1970-01-01"));

# vma and sma
# and vma[p1] - vma[p2]
#periods = c(5, 15, 45, 90, 180);
periods = c(5, 30);
column_names = c();

for (period in periods) {
  column_names = c(column_names, paste('sma', period, sep='_'),
      paste('vma', period, sep='_'));
  quotes[,paste('sma', period, sep='_')] = sma(quotes$price, period);
  quotes[,paste('vma', period, sep='_')] = sma(quotes$volume, period);
}

for (i in 1:length(periods)) {
  if (i == length(periods)) {
    break;
  }
  for (j in (i+1):length(periods)) {
    column_names = c(column_names,
        paste('sma', periods[i], periods[j], sep='_'),
        paste('vma', periods[i], periods[j], sep='_'));
    quotes[,paste('sma', periods[i], periods[j], sep='_')] =
        quotes[,paste('sma', periods[i], sep='_')] -
        quotes[,paste('sma', periods[j], sep='_')];
    quotes[,paste('vma', periods[i], periods[j], sep='_')] =
        quotes[,paste('vma', periods[i], sep='_')] -
        quotes[,paste('vma', periods[j], sep='_')];
  }
}
quotes = na.omit(quotes);

f = as.formula(paste('should_buy ~ ', paste(column_names, collapse='+'))); 
layers = c(length(column_names), length(column_names), length(column_names));
net = neuralnet(f, hidden=layers, quotes);
#print(net);
# plot(net);
test = quotes[,column_names];
results = compute(net, test);

cleanoutput = cbind(quotes$date, quotes$should_buy,
    as.data.frame(results$net.result));
colnames(cleanoutput) = c('date', 'should_buy', 'predicted');
print(cleanoutput);
print(net);
