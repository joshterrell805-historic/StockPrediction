source('lib/loadPreppedData.R');
library(neuralnet);

quotes_all = loadPreppedData();
print('data loaded');


quotes_pos = quotes_all[quotes_all$should_buy == T,];
quotes_pos = quotes_pos[sample(nrow(quotes_pos)),];

quotes_neg = quotes_all[quotes_all$should_buy == F,];
quotes_neg = quotes_neg[sample(nrow(quotes_neg)),];


train_size = 300;
quotes_train = quotes_neg[1:(train_size/2),];
quotes_train = rbind(quotes_train, quotes_pos[1:(train_size/2),]);

test_size  = 800;
quotes_test = quotes_neg[1:(test_size/2),];
quotes_test = rbind(quotes_test, quotes_pos[1:(test_size/2),]);

vars = c();
for (d in c('sma', 'vma')) {
  for (p in c(15, 30, 45)) {
    vars = append(vars, paste(d, 'growth', '15', p, sep='_'));
  }
}
print(vars);


f = as.formula(paste('should_buy ~ ', paste(vars, collapse='+'))); 
layers = c(length(vars), length(vars)); #, length(vars), length(vars),
#    length(vars), length(vars), length(vars), length(vars), length(vars));

train_pos = nrow(quotes_train[quotes_train$should_buy == 1,]);
print(paste('begin training; examples:', train_size, 'positives:', train_pos));
net = neuralnet(f, quotes_train, hidden=layers, threshold=0.01);

res = compute(net, quotes_test[,vars]);
res = cbind(quotes_test$date, quotes_test$should_buy,
    as.data.frame(res$net.result));
colnames(res) = c('date', 'should_buy', 'predicted');

# calculate test error
threshold = 0.5;
tp = nrow(res[res$should_buy == 1 && res$predicted > threshold,]);
fp = nrow(res[res$should_buy == 0 && res$predicted > threshold,]);
fn = nrow(res[res$should_buy == 1 && res$predicted < threshold,]);
tn = nrow(res[res$should_buy == 0 && res$predicted < threshold,]);
test_error = data.frame(a.t=c(tp, fp), a.f=c(fn, tn))
rownames(test_error) = c('p.t', 'p.f');

# plot(net);
print(res[1:10,]);
print(paste('train error:', net$result.matrix[1,]));
print(test_error);
print(paste('precision:', tp / (tp + fp)));
print(paste('recall:', tp / (tp + fn)));
