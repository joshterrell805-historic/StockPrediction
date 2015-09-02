source('lib/loadPreppedData.R');
library(neuralnet);

quotes_all = loadPreppedData();
print('data loaded');

quotes_pos = quotes_all[quotes_all$should_buy == T,];
quotes_pos = quotes_pos[sample(nrow(quotes_pos)),];

quotes_neg = quotes_all[quotes_all$should_buy == F,];
quotes_neg = quotes_neg[sample(nrow(quotes_neg)),];
quotes_neg = quotes_neg[1:(nrow(quotes_pos)*10),];


percentTrain = 0.10;
trainPosEnd = floor(nrow(quotes_pos) * percentTrain);
trainNegEnd = floor(nrow(quotes_neg) * percentTrain);

quotes_train = quotes_neg[1:trainNegEnd,];
quotes_train = rbind(quotes_train, quotes_pos[1:trainPosEnd,]);

quotes_test = quotes_neg[(trainNegEnd+1):nrow(quotes_neg),];
quotes_test = rbind(quotes_test, quotes_pos[(trainPosEnd+1):nrow(quotes_pos),]);

vars = colnames(quotes_all)[21:length(quotes_all)];
print(vars);

f = as.formula(paste('should_buy ~ ', paste(vars, collapse='+'))); 
# layers
layers = c(length(vars), length(vars), length(vars), length(vars),
    length(vars), length(vars));#, length(vars), length(vars), length(vars));

train_pos = nrow(quotes_train[quotes_train$should_buy == 1,]);
print(paste('begin training; examples:', trainPosEnd+trainNegEnd, 'positives:',
    trainPosEnd));
net = neuralnet(f, quotes_train, hidden=layers, threshold=0.01);

res = compute(net, quotes_test[,vars]);
res = cbind(quotes_test$date, quotes_test$should_buy,
    as.data.frame(res$net.result));
colnames(res) = c('date', 'should_buy', 'predicted');

# calculate test error
threshold = 0.5;
p = res[res$should_buy == T,];
n = res[res$should_buy == F,];
tp = nrow(p[p$predicted > threshold,]);
fp = nrow(n[n$predicted > threshold,]);
fn = nrow(p[p$predicted < threshold,]);
tn = nrow(n[n$predicted < threshold,]);
test_error = data.frame(a.t=c(tp, fn), a.f=c(fp, tn))
rownames(test_error) = c('p.t', 'p.f');

# plot(net);
print(res[1:10,]);
print(paste('train error:', net$result.matrix[1,]));
print(test_error);

precision = tp / (tp + fp); recall = tp / (tp + fn);
print(paste('precision:', precision));
print(paste('recall:', recall));
