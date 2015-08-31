growth = function(quotes, growth_field, period) {
  sapply(1:nrow(quotes), function(i) {
    if (i <= period) {
      NA;
    } else {
      q = quotes[i,];
      this = q[, growth_field];
      last =
          tail(quotes[quotes$timestamp < q$timestamp, growth_field], period)[1];
      (this - last) / last * 100;
    }
  });
};
