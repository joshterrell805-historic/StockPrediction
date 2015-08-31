library('ggplot2');
source('lib/findBuyIndexes.R');
source('lib/sma.R');
source('lib/growth.R');

quotes          = read.csv('data/BBEP.csv');
quotes          = na.omit(quotes);

quotes$date     = as.Date(as.POSIXct(quotes$timestamp, origin="1970-01-01"))
quotes$price    = rowMeans(subset(quotes, select=c(high, low)));

quotes$sma_015  = sma(quotes, 'price', 15);
quotes$sma_030  = sma(quotes, 'price', 30);
quotes$sma_060  = sma(quotes, 'price', 60);
quotes$vma_060  = sma(quotes, 'volume', 60);

quotes          = na.omit(quotes);
# print(nrow(quotes));

quotes$price_growth_15_1 = growth(quotes, 'sma_015', 1);
quotes$volume_growth_60_1 = growth(quotes, 'vma_060', 1);

quotes = quotes[16:nrow(quotes), ];
# print(nrow(quotes)); quotes = na.omit(quotes); print(nrow(quotes));

rownames(quotes) = 1:nrow(quotes);
minSellToBuyRatio = 1.22;
buyIndexes       = findBuyIndexes(quotes, maxHoldDays=30,
    minSellToBuyRatio=minSellToBuyRatio);
buyIndexes       = buyIndexes[buyIndexes>60];
buyIndexes       = buyIndexes[buyIndexes<(nrow(quotes)-30)];
print(buyIndexes);
buyIndex = buyIndexes[7];
buyDate = quotes[buyIndex,]$date;

quotes = quotes[(buyIndex-60-1):(buyIndex+30-1),];
buyIndex = NA;

growthSpan = max(quotes$price_growth_15_1) - min(quotes$price_growth_15_1);
ylimits = c(floor(min(quotes$price) - growthSpan), ceiling(max(quotes$price)));
quotes$price_growth_15_1 = quotes$price_growth_15_1 + ylimits[1] + growthSpan/2;
# print(nrow(quotes)); quotes = na.omit(quotes); print(nrow(quotes));
quotes$volume_growth_60_1 = quotes$volume_growth_60_1 + ylimits[1] + growthSpan/2;

fn_vol <- smooth.spline(x=quotes$timestamp, y=quotes$volume_growth_60_1);
quotes$volume_growth_smooth_60_1 = data.frame(predict(fn_vol, quotes$timestamp))$y;

buyQuote = quotes[quotes$date == buyDate,];
quotesAfter = head(quotes[quotes$date > buyDate,], 30);
sellQuotes  = quotesAfter[quotesAfter$price >=
    buyQuote$price * minSellToBuyRatio,];
print(rbind(buyQuote, sellQuotes));

graph <- ggplot() +
    geom_line(data=quotes, aes(x=date, y=price), colour='black') + 

    geom_point(data=buyQuote, aes(x=date, y=price), color='green') +
    geom_point(data=sellQuotes, aes(x=date, y=price), color='red') +

    geom_smooth(data=quotes, aes(x=date, y=sma_015), colour='#661111',
        stat='identity') +
    geom_smooth(data=quotes, aes(x=date, y=sma_030), colour='#AA1111',
        stat='identity') +
    geom_smooth(data=quotes, aes(x=date, y=sma_060), colour='#FF1111',
        stat='identity') +

    geom_smooth(data=quotes, aes(x=date, y=price_growth_15_1),
        colour='#111199', stat='identity') +
    geom_smooth(data=quotes, aes(x=date, y=volume_growth_smooth_60_1),
        colour='#991199', stat='identity') +
#    geom_smooth(data=quotes, aes(x=date, y=volume_growth),
#        colour='#77BB77', stat='identity') +

    geom_hline(yintercept = ylimits[1] + growthSpan/2) +
    scale_y_continuous(limit=ylimits, breaks=ylimits[1]:ylimits[2]) +
    scale_x_date(breaks=quotes[c(1,(1:15)*6+1), 'date']) +
    guides(colour=F) +
    xlab('date') +
    ylab('price');

print(graph);
