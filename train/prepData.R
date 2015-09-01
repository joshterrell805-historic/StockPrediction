source('lib/associateFeatures.R');

symbols         = read.csv('data/symbols.csv');

apply(symbols, 1, function(symbol) {
  filename = paste('data/', symbol, '.csv', sep='');

  quotes = read.csv(filename);
  quotes = associateFeatures(quotes);

  filename = paste('data/', symbol, '.prepped.csv', sep='');
  write.csv(quotes, filename); 

  print(paste('finished', symbol));
});
