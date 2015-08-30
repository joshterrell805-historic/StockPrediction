# calculate simple moving average of data
# assumes data is at least 'count' long
sma = function(data, column, count) {
  seconds_per_day = 24*60*60;
  return(sapply(1:nrow(data), function(i) {
    if (i < count) {
      return(NA);
    } else {
      return(sum(data[(i-count+1):i, column]) / count);
    }
  }));
};
