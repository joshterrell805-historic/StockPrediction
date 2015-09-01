growth = function(quotes, growth_field, period) {
  sapply(1:nrow(quotes), function(i) {
    if (i <= period) {
      NA;
    } else {
      q = quotes[i,];
      last =
          tail(quotes[quotes$timestamp < q$timestamp, growth_field], period)[1];
      if (is.na(last) || last == 0) {
        NA;
      } else {
        this = q[, growth_field];
        (this - last) / last * 100;
      }
    }
  });
};
