# calculate simple moving average of data
# assumes data is at least 'count' long
sma = function(data, count) {
  return(sapply(1:length(data), function(i) {
    if (i < count) {
      return(NA);
    } else {
      return(mean(
        data[(i-count+1):i]
      ));
    }
  }));
};
