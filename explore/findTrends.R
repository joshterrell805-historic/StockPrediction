quotes          = read.csv('data/BBEP.csv');
quotes          = na.omit(quotes);

# attempt 1
# if h2 > h1, what prob h3 > h2?
# if l2 < l1, what prob l3 < l2?

lastL = NULL;
lastH = NULL;
trendDown = F;
trendUp = F;
contUp = 0;
stopUp = 0;
contDown = 0;
stopDown = 0;

sapply(1:nrow(quotes), function(i) {
  thisL = quotes[i, 'low']
  thisH = quotes[i, 'high'];

  if (i >= 2) {
    thisTrendDown = thisL - lastL < -(lastL * 0.005);
    thisTrendUp = thisH - lastH > lastH * 0.005;

    # if (thisTrendDown & thisTrendUp) {
    #   thisTrendDown = F;
    #   thisTrendUp = F;
    # }

    if (i >= 3) {
      if (trendUp) {
        if (thisTrendUp) {
          contUp <<- contUp + 1;
        } else {
          stopUp <<- stopUp + 1;
        }
      }
      if (trendDown) {
        if (thisTrendDown) {
          contDown <<- contDown + 1;
        } else {
          stopDown <<- stopDown + 1;
        }
      }
    }

    trendDown <<- thisTrendDown;
    trendUp <<- thisTrendUp;
  }

  lastL <<- thisL;
  lastH <<- thisH;
});

d = data.frame(up=c(contUp, stopUp), down=c(contDown, stopDown));
rownames(d) = c('cont', 'stop');
print(d);
