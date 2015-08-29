require.config({
  paths: {
    d3: 'https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.6/d3.min',
    c3: 'https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.10/c3.min',
    // plugins
    text: 'https://cdnjs.cloudflare.com/ajax/libs/require-text/2.0.12/text.min',
    json: 'https://cdnjs.cloudflare.com/ajax/libs/requirejs-plugins/1.0.3/json.min',
    lodash: 'https://cdnjs.cloudflare.com/ajax/libs/lodash.js/3.10.1/lodash.min',
  }
});

require(['d3', 'c3', 'lodash', 'json!data/CJES.json'],
    function(d3, c3, _, rawData) {
  rawData.timestamp = _.map(rawData.timestamp, function(ts) {return ts*1000;});
  var index = 0;
  var count = 30;

  function columnsFrom(data, index, count) {
    return [
      ['high'].concat(
          data.indicators.quote[0].high.slice(index, index + count)),
      ['low'].concat(
          data.indicators.quote[0].low.slice(index, index + count)),
      ['x'].concat(data.timestamp.slice(index, index + count)),
    ];
  }

  function chartData(data, beginIndex, count) {
    return {
      columns: columnsFrom(data, beginIndex, count),
      x: 'x',
    };
  }

  function nextChartData() {
    return chartData(rawData, index++, count);
  }

  var chart = c3.generate({
    bindto: '#chart',
    data: nextChartData(),
    transition: {
      duration: 0,
    },
    axis: {
      x: {
        type: 'timeseries',
        tick: {
          format: '%Y-%m-%d',
        },
      },
    },
  });

  setInterval(function() {
    chart.load(nextChartData());
  }, 1000)
});
