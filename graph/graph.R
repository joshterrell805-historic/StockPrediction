library('ggplot2');

data = read.csv('data/CJES.csv');
data = data[100:130,];

data$date = as.Date(as.POSIXct(data$timestamp, origin="1970-01-01"))
data$price = rowMeans(subset(data, select=c(high, low)));

graph <- ggplot() +
    geom_line(data=data, aes(x=date, y=high, colour='high')) + 
    geom_line(data=data, aes(x=date, y=price, colour='price')) + 
    geom_line(data=data, aes(x=date, y=low, colour='low')) +
    scale_colour_manual(
        values=c('red', 'black', 'gray'),
        breaks=c('high', 'low', 'price')
    ) +
    labs(colour='Legend');

print(graph);
