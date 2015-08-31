library('ggplot2');
source('lib/findBuyIndexes.R');
source('lib/sma.R');

quotes         = read.csv('data/CJES.csv');
quotes         = na.omit(quotes);
buyIndexes     = findBuyIndexes(quotes, maxHoldDays=30, minSellToBuyRatio=1.2);
buyIndexes     = buyIndexes[buyIndexes > 60];
print(buyIndexes);
print(length(buyIndexes));
buyIndex = buyIndexes[7];

quotes$date     = as.Date(as.POSIXct(quotes$timestamp, origin="1970-01-01"))
quotes$price    = rowMeans(subset(quotes, select=c(high, low)));
quotes$sma_015  = sma(quotes, 'price', 15);
quotes$sma_030  = sma(quotes, 'price', 30);
quotes$sma_060  = sma(quotes, 'price', 60);
quotes$vma_060  = sma(quotes, 'volume', 60);
quotes          = na.omit(quotes);
growth_field = 'sma_015';
quotes$price_growth = sapply(1:nrow(quotes), function(i) {
  if (i == 1) {
    return(NA);
  } else {
    q = quotes[i,];
    this = q[,growth_field];
    last = tail(quotes[quotes$timestamp < q$timestamp, growth_field], 1);
    (this - last) / last * 100;
  }
});
growth_field = 'vma_060';
quotes$volume_growth = sapply(1:nrow(quotes), function(i) {
  if (i == 1) {
    return(NA);
  } else {
    q = quotes[i,];
    this = q[,growth_field];
    last = tail(quotes[quotes$timestamp < q$timestamp, growth_field], 1);
    (this - last) / last * 100;
  }
});
quotes = quotes[2:nrow(quotes), ];

quotes = quotes[(buyIndex-60):(buyIndex+30),];

growthSpan = max(quotes$price_growth) - min(quotes$price_growth);
ylimits = c(floor(min(quotes$price) - growthSpan), ceiling(max(quotes$price)));
quotes$price_growth = quotes$price_growth + ylimits[1] + growthSpan/2;
quotes$volume_growth = quotes$volume_growth + ylimits[1] + growthSpan/2;

fn_vol <- smooth.spline(x=quotes$timestamp, y=quotes$volume_growth);
quotes$volume_growth_smooth = data.frame(predict(fn_vol, quotes$timestamp))$y;

graph <- ggplot() +
    geom_line(data=quotes, aes(x=date, y=price), colour='black') + 
    geom_smooth(data=quotes, aes(x=date, y=sma_015), colour='#661111',
        stat='identity') +
    geom_smooth(data=quotes, aes(x=date, y=sma_030), colour='#AA1111',
        stat='identity') +
    geom_smooth(data=quotes, aes(x=date, y=sma_060), colour='#FF1111',
        stat='identity') +

    geom_smooth(data=quotes, aes(x=date, y=price_growth),
        colour='#111199', stat='identity') +
    geom_smooth(data=quotes, aes(x=date, y=volume_growth_smooth),
        colour='#119911', stat='identity') +
    geom_smooth(data=quotes, aes(x=date, y=volume_growth),
        colour='#119911', stat='identity') +
    geom_hline(yintercept = ylimits[1] + growthSpan/2) +
    scale_y_continuous(limit=ylimits, breaks=ylimits[1]:ylimits[2]) +
    scale_x_date(breaks=quotes[c(1,(1:15)*6+1), 'date']) +
    guides(colour=F) +
    xlab('date') +
    ylab('price');

print(graph);
