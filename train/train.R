source('lib/sma.R'); 
source('lib/findBuyIndexes.R'); 
source('lib/growth.R'); 
library(neuralnet);

quotes         = read.csv('data/CJES.csv');
quotes         = na.omit(quotes);
buyIndexes     = findBuyIndexes(quotes, maxHoldDays=30, minSellToBuyRatio=1.2);
buyTimestamps  = quotes[buyIndexes, 'timestamp'];

quotes$should_buy = as.integer(quotes$timestamp %in% buyTimestamps);
quotes$price      = rowMeans(subset(quotes, select=c(high, low)));
quotes$date       = as.Date(as.POSIXct(quotes$timestamp, origin="1970-01-01"));

# vma and sma
# and vma[p1] - vma[p2]
#periods = c(5, 15, 45, 90, 180);
periods = c(15, 60);
vars = c();

for (period in periods) {
  quotes[,paste('sma', period, sep='_')] = sma(quotes, 'price', period);
  quotes[,paste('vma', period, sep='_')] = sma(quotes, 'volume', period);
}

for (p in c(15, 30, 45)) {
  for (m in c('sma', 'vma')) {
    name = paste(m, 'growth', '15', p, sep='_');
    vars = append(vars, name);
    quotes[,name] =
        growth(quotes, paste(m, '15', sep='_'), p);
  }
}

print(vars);

quotes = na.omit(quotes);
print(nrow(quotes));

f = as.formula(paste('should_buy ~ ', paste(vars, collapse='+'))); 
layers = c(length(vars), length(vars), length(vars), length(vars), length(vars),
    length(vars));
net = neuralnet(f, hidden=layers, threshold=0.001, quotes);
# plot(net);
test = quotes[,vars];
results = compute(net, test);

cleanoutput = cbind(quotes$date, quotes$should_buy,
    as.data.frame(results$net.result));
colnames(cleanoutput) = c('date', 'should_buy', 'predicted');
print(cleanoutput);
print(net);

# print(quotes[1:10,]);
