# calculate simple moving average of data
# assumes data is at least 'count' long
sma = function(data, column, count) {
  return(sapply(1:nrow(data), function(i) {
    if (i < count) {
      return(NA);
    } else {
      # left sided
      start = i - count + 1;
      return(sum(data[start:(start+count-1), column] / count));
    }
  }));
};
