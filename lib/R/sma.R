# calculate simple moving average of data
# assumes data is at least 'count' long
sma = function(data, column, count) {
  seconds_per_day = 24*60*60;
  return(sapply(1:nrow(data), function(i) {
    if (i < floor(count/2)) {
      return(NA);
    } else {
      start = i - floor(count/2);
      return(sum(data[start:(start+count-1), column]) / count);
    }
  }));
};
