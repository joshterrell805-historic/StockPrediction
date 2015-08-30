source('lib/sma.R'); 

quotes         = read.csv('data/CJES.csv');
tradingIndexes = read.csv('data/CJES_tradingIndexes.csv');

quotes$price   = rowMeans(subset(quotes, select=c(high, low)));
quotes$date    = as.Date(as.POSIXct(quotes$timestamp, origin="1970-01-01"));
quotes$sma_5   = sma(quotes$price, 5);
quotes$sma_15  = sma(quotes$price, 15);

# quotes$sma_5 = colMeans(matrix(data$price, nrow=5));
# print(quotes[1:30,]);

