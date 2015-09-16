library(neuralnet);

quotes_all = read.csv('data/AAPL.labeled.csv');
quotes_all = quotes_all[sample(nrow(quotes_all)),];
print('data loaded');

pos = 1000;
neg = 4000;

quotes_pos    = quotes_all[quotes_all$test == T,];
quotes_te_pos = quotes_pos[1:pos,];
quotes_tr_pos = quotes_pos[(pos+1):(pos*2),];

quotes_neg    = quotes_all[quotes_all$test == F,];
quotes_te_neg = quotes_neg[1:neg,];
quotes_tr_neg = quotes_neg[(neg+1):nrow(quotes_neg),];
quotes_tr_neg = head(quotes_tr_neg[quotes_tr_neg$train == F,], n=neg);

quotes_tr = rbind(quotes_tr_pos, quotes_tr_neg);
quotes_te = rbind(quotes_te_pos, quotes_te_neg);

vars = colnames(quotes_all);
vars = vars[substr(vars,1,4) == 'feat'];
print(vars);

# layers
layers = #c(length(vars)*14, length(vars)*13, length(vars)*12, length(vars)*11,
    c(length(vars)*10, length(vars)*9, length(vars)*8, length(vars)*7,
    length(vars)*6, length(vars)*5, length(vars)*4, length(vars)*3,
    length(vars)*2, length(vars));
# layers = c(length(vars), length(vars), length(vars), length(vars),
#     floor(length(vars)/2), floor(length(vars)/2), floor(length(vars)/2));

# layers = c(length(vars), length(vars));#, length(vars), length(vars),
#    length(vars), length(vars));#, length(vars), length(vars), length(vars));

print(paste('begin training; examples:', nrow(quotes_tr), 'positives:',
    nrow(quotes_tr_pos)));

f = as.formula(paste('test ~ ', paste(vars, collapse='+'))); 
net = neuralnet(f, quotes_tr, hidden=layers, threshold=0.1);

res = compute(net, quotes_te[,vars]);
res = cbind(quotes_te$date, quotes_te$test,
    as.data.frame(res$net.result));
colnames(res) = c('date', 'test', 'predicted');

# calculate test error
threshold = 0.5;
p = res[res$test == T,];
n = res[res$test == F,];
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
