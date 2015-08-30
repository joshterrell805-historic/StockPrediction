source('lib/sma.R'); 
library(neuralnet)


quotes         = read.csv('data/CJES.csv');
tradingIndexes = read.csv('data/CJES_tradingIndexes.csv');
buyTimestamps  = quotes[tradingIndexes[,'buy_index'], 'timestamp'];

quotes$should_buy = as.integer(quotes$timestamp %in% buyTimestamps);
quotes$price      = rowMeans(subset(quotes, select=c(high, low)));
quotes$date       = as.Date(as.POSIXct(quotes$timestamp, origin="1970-01-01"));

quotes$price_prev = sapply(1:nrow(quotes), function(i) {
  if (i < 2) {
    return(NA);
  } else {
    return(quotes[i-1, 'price']);
  }
});

# print(quotes[900:920,]);

## vma and sma
## and vma[p1] - vma[p2]
#periods = c(5, 15, 45, 90, 180);
#
#for (period in periods) {
#  quotes[,paste('sma', period)] = sma(quotes$price, period);
#  quotes[,paste('vma', period)] = sma(quotes$volume, period);
#}
#
#for (i in 1:length(periods)) {
#  if (i == length(periods)) {
#    break;
#  }
#  for (j in (i+1):length(periods)) {
#    quotes[,paste('sma', periods[i], periods[j])] =
#        quotes[,paste('sma', periods[i])] - quotes[paste('sma', periods[j])];
#    quotes[,paste('vma', periods[i], periods[j])] =
#        quotes[,paste('vma', periods[i])] - quotes[paste('vma', periods[j])];
#  }
#}
#print(quotes[180:185,]);

quotes = quotes[!is.na(quotes$price),];
quotes = quotes[!is.na(quotes$price_prev),];

net <- neuralnet(should_buy~price+price_prev, quotes);
print(net);
# plot(net);
test = quotes[,c('price', 'price_prev')];
# print(test);
results = compute(net, test);
#print(results$net.result);

cleanoutput <- cbind(quotes$price, quotes$price_prev, quotes$should_buy,
    as.data.frame(results$net.result));
colnames(cleanoutput) <- c('price','price_prev','should_buy','predicted');
print(cleanoutput);
