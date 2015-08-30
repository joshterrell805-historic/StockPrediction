library('ggplot2');

quotes         = read.csv('data/CJES.csv');
tradingIndexes = read.csv('data/CJES_tradingIndexes.csv');

quotes$date    = as.Date(as.POSIXct(quotes$timestamp, origin="1970-01-01"))
quotes$price   = rowMeans(subset(quotes, select=c(high, low)));
quotes$sma_005  = sma(quotes$price, 5);
quotes$sma_015  = sma(quotes$price, 15);
quotes$sma_045  = sma(quotes$price, 45);
quotes$sma_090  = sma(quotes$price, 90);

quotes = quotes[(tradingIndexes[3,1]-90):tradingIndexes[3,2],];


graph <- ggplot() +
    geom_line(data=quotes, aes(x=date, y=price, colour='price')) + 
    geom_smooth(data=quotes, aes(x=date, y=sma_005, colour='sma_005'),
        stat='identity') + 
    geom_smooth(data=quotes, aes(x=date, y=sma_015, colour='sma_015'),
        stat='identity') +
    geom_smooth(data=quotes, aes(x=date, y=sma_045, colour='sma_045'),
        stat='identity') +
    geom_smooth(data=quotes, aes(x=date, y=sma_090, colour='sma_090'),
        stat='identity') +
    scale_colour_manual(
        values=c('black', '#551111', '#881111', '#BB1111', '#FF1111'),
        breaks=c('price', 'sma_005', 'sma_015', 'sma_045', 'sma_090')
    ) +
    labs(colour='Legend') +
    xlab('date') +
    ylab('price');

print(graph);
