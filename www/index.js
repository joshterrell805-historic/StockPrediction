require.config({
  paths: {
    d3: 'https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.6/d3.min',
    c3: 'https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.10/c3.min',
  }
});

require(['d3', 'c3'], function(d3, c3) {
  var chart = c3.generate({
    bindto: '#chart',
    data: {
      columns: [
        ['data1', 30, 200, 100, 400, 150, 250],
        ['data2', 50, 20, 10, 40, 15, 25]
      ],
      types: {
        'data1': 'line',
        'data2': 'line',
      },
    },
  });
});
