source('lib/sma.R');
ema = function(data, column, count) {
  multiplier = (2 / (count + 1));
  prev = NA;
  return(sapply(1:nrow(data), function(i) {
    if (i < count) {
      prev <<- NA;
    } else if (i == count) {
      prev <<- sma(data[1:count,], column, count)[count];
    } else {
      prev <<- (data[i, column] - prev) * multiplier + prev;
    }
    prev;
  }));
};
