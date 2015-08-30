library('ggplot2');

doIt = function() {
  quotes         = read.csv('data/CJES.csv');
  tradingIndexes = read.csv('data/CJES_tradingIndexes.csv');
  quotes = quotes[tradingIndexes[3,1]:tradingIndexes[3,2],];

  quotes$date = as.Date(as.POSIXct(quotes$timestamp, origin="1970-01-01"))
  quotes$price = rowMeans(subset(quotes, select=c(high, low)));

  graph <- ggplot() +
      geom_line(data=quotes, aes(x=date, y=high, colour='high')) + 
      geom_line(data=quotes, aes(x=date, y=price, colour='price')) + 
      geom_line(data=quotes, aes(x=date, y=low, colour='low')) +
      scale_colour_manual(
          values=c('red', 'black', 'gray'),
          breaks=c('high', 'low', 'price')
      ) +
      labs(colour='Legend') +
      xlab('date') +
      ylab('price');

  print(graph);
}

doIt();
