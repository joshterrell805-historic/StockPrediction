loadPreppedData = function() {
  symbols = read.csv('data/symbols.csv');
  frame = NULL;

  apply(symbols, 1, function(symbol) {
    filename = paste('data/', symbol, '.prepped.csv', sep='');
    quotes = read.csv(filename);

    if (is.null(frame)) {
      frame <<- quotes;
    } else {
      frame <<- rbind(frame, quotes)
    }
  });

  frame;
}
