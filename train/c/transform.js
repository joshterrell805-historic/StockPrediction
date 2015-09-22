var symbol = process.argv[2] || 'AAPL';
var train = 32,
    test = 31,
    featBegin = 14
    featEnd = 30;

var csv = require('csv'),
    fs = require('fs'),
    Promise = require('bluebird'),
    _ = require('lodash');

Promise.promisify(csv.parse)(fs.readFileSync('data/' + symbol +
    '.labeled.3.csv'))
.then(function(data) {
  var testPos = 1000,
      testNeg = 2000,
      trainPos = Number.POSITIVE_INFINITY,
      trainNeg = Number.POSITIVE_INFINITY;
    
  data = _.shuffle(data);

  var usedIndexes = [];

  var dataTestPos = [];
  for (var i = 0; dataTestPos.length < testPos && i < data.length; ++i) {
    var row = data[i];
    if (row[test] === 'TRUE' && usedIndexes.indexOf(row[0]) === -1) {
      dataTestPos.push(row);
      usedIndexes.push(row[0]);
    }
  }

  var dataTrainPos = [];
  for (var i = 0; dataTrainPos.length < trainPos && i < data.length; ++i) {
    var row = data[i];
    if (row[train] === 'TRUE' && usedIndexes.indexOf(row[0]) === -1) {
      dataTrainPos.push(row);
      usedIndexes.push(row[0]);
    }
  }

  var dataTestNeg = [];
  for (var i = 0; dataTestNeg.length < testNeg && i < data.length; ++i) {
    var row = data[i];
    if (row[test] === 'FALSE' && usedIndexes.indexOf(row[0]) === -1) {
      dataTestNeg.push(row);
      usedIndexes.push(row[0]);
    }
  }

  var dataTrainNeg = [];
  for (var i = 0; dataTrainNeg.length < trainNeg && i < data.length; ++i) {
    var row = data[i];
    if (row[train] === 'FALSE' && usedIndexes.indexOf(row[0]) === -1) {
      dataTrainNeg.push(row);
      usedIndexes.push(row[0]);
    }
  }

  write(dataTestPos, 'test', 'pos');
  write(dataTestNeg, 'test', 'neg');
  write(dataTrainPos, 'train', 'pos');
  write(dataTrainNeg, 'train', 'neg');
  //write(dataTrainPos.concat(dataTrainNeg), 'train');
  //write(dataTestPos.concat(dataTestNeg), 'test');
})
.done();

function write(data, name, dir) {
  var approve = name === 'train' ? train : test;
  data = _.map(data, function(row) {
    return _.slice(row, featBegin, featEnd+1).join(' ') + '\n' +
        (row[approve] === 'TRUE' ? '1' : '-1');
  });
  data = data.length + ' ' + (featEnd - featBegin + 1) + ' 1\n' +
      data.join('\n');

  var filename = 'data/' + symbol + '.' + name + (dir?'.'+dir:'') + '.fann';
  fs.writeFileSync(filename, data);
}
