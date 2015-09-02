# calculate simple moving average of data
# assumes data is at least 'count' long
sma = function(data, column, count) {
  return(sapply(1:nrow(data), function(i) {
    # two sided
    # if (i < floor(count/2)) {
    # one sided
    if (i <= count) {
      return(NA);
    } else {
      # two sided
      # start = i - floor(count/2);
      # left sided
      start = i - count;
      return(sum(data[start:(start+count-1), column] / count));
    }
  }));
};
