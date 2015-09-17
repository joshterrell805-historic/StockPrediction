source('lib/ema.R');

# associate the points at the start and end of each hour
associateHourBoundaries = function(quotes) {
  minTimestamp = min(quotes$timestamp);
  maxTimestamp = max(quotes$timestamp);
  minHour = floor(minTimestamp/3600);
  maxHour = floor(maxTimestamp/3600);

  quotes$hourStart = F;
  quotes$hourEnd = F;

  sapply(minHour:maxHour, function(hour) {
    start = hour*3600;
    end = start + 3600;
    hourStart = quotes[quotes$timestamp >= start,];
    hourEnd = hourStart[hourStart$timestamp < end,];

    timestampStart = head(hourStart, n=1)$timestamp;
    timestampEnd = tail(hourEnd, n=1)$timestamp;

    quotes[quotes$timestamp == timestampStart, 'hourStart'] <<- T;
    quotes[quotes$timestamp == timestampEnd, 'hourEnd'] <<- T;
  });
  
  last = quotes[nrow(quotes),];
  if (last$hourEnd && last$hourStart) {
    quotes = quotes[1:nrow(quotes)-1,];
  }

  hourStarts = quotes[quotes$hourStart == T,];
  hourEnds = quotes[quotes$hourEnd == T,];
  stopifnot(nrow(hourStarts) == nrow(hourEnds));

  quotes;
};

# associate the average price over the last hour for every point
associateHourPrice = function(quotes) {
  hourStarts = quotes[quotes$hourStart == T,];
  hourEnds = quotes[quotes$hourEnd == T,];

  sapply(1:nrow(hourStarts), function(i) {
    hourStart = hourStarts[i,];
    hourEnd = hourEnds[i,];
    hour = quotes[quotes$timestamp >= hourStart$timestamp,];
    hour = hour[hour$timestamp <= hourEnd$timestamp,];
    quotes[rownames(hour), 'hourPrice'] <<- mean(hour$price, trim=0.1);
  });

  quotes;
};

# associate the max growth percent between two one-hour-segments in
# `maxHoldHours` hours.
associateMaxGrowth = function(quotes, maxHoldHours=8) {
  hourStarts = quotes[quotes$hourStart == T,];

  sapply(1:(nrow(hourStarts)-23), function(i) {
    maxPrice = max(hourStarts[(i+1):(i+23), 'hourPrice']);
    thisPrice = hourStarts[i, 'hourPrice'];
    maxGrowth = (maxPrice - thisPrice) / thisPrice;
    hour = floor(hourStarts[i, 'timestamp'] / 3600);
    quotes[floor(quotes$timestamp / 3600) == hour, 'maxGrowth'] <<- maxGrowth;
  });

  quotes;
};

associateEmas = function(quotes, periods=c(4,12,36,120,360)) {
  lapply(periods, function(period) {
    quotes[,paste('ema', period, sep='')] <<- ema(quotes, 'price', period);
  });
  quotes;
};

# associate features on the data
associateFeatures = function(quotes, periods=c(4,12,36,120,360)) {
  quotes$date      = as.POSIXlt(quotes$timestamp, origin="1970-01-01");
  quotes$feat_hour = quotes$date$hour;
  quotes$feat_wday = quotes$date$wday;

  # position relative to mean: (ema120 - ema360) / ema360 ...
  sapply(1:(length(periods)-1), function(i) {
    periodSmall = periods[i];
    periodBig = periods[i+1];
    emaSmall = quotes[,paste('ema', periodSmall, sep='')];
    emaBig = quotes[,paste('ema', periodBig, sep='')];
    quotes[,paste('feat_pos_ema', periodSmall, periodBig, sep='_')] <<-
      (emaSmall - emaBig) / emaBig;
  });

  # velocity: delta_ema(360, 180), delta_ema(120, 60) ...
  vel_emas = data.frame();
  lapply(periods, function(period) {
    hPeriod = period/2;
    field = paste('ema', period, sep='');
        sapply(1:nrow(quotes), function(i) {
          to = quotes[i, field];
          from = quotes[i-hPeriod, field];
          if (i <= hPeriod || is.na(to) || is.na(from) || to == 0 ||
              from == 0) {
            vel_emas[i, paste(period)] <<- NA;
            quotes[i,paste('feat_vel_ema', period, sep='_')] <<- NA;
          } else {
            vel_ema = (to - from) / hPeriod;
            vel_emas[i, paste(period)] <<- vel_ema;
            quotes[i,paste('feat_vel_ema', period, sep='_')] <<-
                vel_ema / abs(from);
          }
        });
  });

  # accel: delta_delta_ema(360, 180, 180) delta_delta_ema(120, 60, 60) ...
  lapply(periods, function(period) {
    qPeriod = 1;
    quotes[,paste('feat_acc_ema', period, sep='_')] <<-
        sapply(1:nrow(quotes), function(i) {
          to = vel_emas[i, paste(period)];
          from = vel_emas[i-qPeriod, paste(period)];
          if (i <= qPeriod || is.na(to) || is.na(from) || to == 0 ||
              from == 0) {
            NA;
          } else {
            (to - from) / qPeriod / abs(from);
          }
        });
  });

  # variance
  quotes[,'feat_var_12'] = sapply(1:nrow(quotes), function(i) {
    if (i < 12) {
      NA;
    } else {
      var(quotes[(i-11):i, 'price']) / sqrt(12);
    }
  });

  quotes;
};

# should the stock be bought (testing)?
associateTest = function(quotes, minGrowth=0.010) {
  quotes$test = quotes$maxGrowth >= minGrowth;
  quotes;
};

# should the stock be bought (training)?
# T, F, or NULL
# null means don't train with the datapoint.
associateTrain = function(quotes, minGrowth=0.014, limitRejectGrowth=0.003) {
  quotes$train = NA;
  sapply(1:nrow(quotes), function(i) {
    this = quotes[i,];
    if (this$test == T) {
      quotes[i, 'train'] <<- T;
    } else if (this$maxGrowth < limitRejectGrowth) {
      quotes[i, 'train'] <<- F;
    }
  });

  quotes;
};


labelData = function(name) {
  quotes = read.csv(paste('data/', name, '.csv', sep=''), sep='\t');
  quotes = associateHourBoundaries(quotes);
  quotes = associateHourPrice(quotes);
  quotes = associateMaxGrowth(quotes);
  quotes = associateEmas(quotes);
  quotes = associateFeatures(quotes);
  quotes = na.omit(quotes);
  quotes = associateTest(quotes);
  quotes = associateTrain(quotes);
  write.csv(quotes, paste('data/', name, '.labeled.3.csv', sep=''));
};

labelData('AAPL');
