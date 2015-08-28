require.config({
  paths: {
    d3: 'https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.6/d3.min',
    c3: 'https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.10/c3.min',
    // plugins
    text: 'https://cdnjs.cloudflare.com/ajax/libs/require-text/2.0.12/text.min',
    json: 'https://cdnjs.cloudflare.com/ajax/libs/requirejs-plugins/1.0.3/json.min',
  }
});

require(['d3', 'c3', 'json!CJES.json'], function(d3, c3, rawData) {
  var data = {
    high: rawData.indicators.quote[0].high.slice(-30),
    low: rawData.indicators.quote[0].low.slice(-30),
  };
  data.high.unshift('high');
  data.low.unshift('low');

  var chart = c3.generate({
    bindto: '#chart',
    data: {
      columns: [
        data.high,
        data.low,
      ],
      /*
      types: {
        'high': 'line',
        'low': 'line',
      },
      */
    },
  });
});
