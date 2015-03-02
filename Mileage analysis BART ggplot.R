# This script reads in a data file containing driving distances and 
# fares between every pair of stations
# served by Bay Area Rapid Transit, as of January 1, 2013. 
# Self and Airport are indicator variables
# Self = 1 if and only if From Station = To Station
# Airport = 1 if and only if San Francisco International Airport 
# is the To or From Station
# I assume Fare is symmetric, so that traveling from Station A to 
# Station B costs the same as B to A
# written by Timothy Sweetser, 2013. 
# http://sites.google.com/site/tsweetser

library(ggplot2)

writeYN <- FALSE
BART.raw <- read.csv(
  "F:/BART Project/data/bart/BART all possible trips.csv")
BART.raw$Self <- as.factor(BART.raw$Self) #all zeros, by design

# include each trip (one pair of stations) only once
keepers <- NULL
for (i in 1: nrow(BART.raw)) {
  sister.row <- intersect(which(BART.raw$To == BART.raw$From[i]),
                      which(BART.raw$From == BART.raw$To[i]))
  keepers <- c(keepers,min(i,sister.row,na.rm=T))
}
BART.fares <- BART.raw[unique(keepers), ]

# fit a linear regression model
m <- lm(Fare ~ 0 + Miles,data=BART.fares, offset=rep(1.75,nrow(BART.fares)))
ma <- update(m, ~.+Airport)
anova(m, ma) # p value < .05: reject the null, keep Airport in the model

# use this mask to color-code airport and non-airport trips
airport.mask <- BART.fares$Airport == 1

# outliers: 911 San Bruno - SFO, 921 SFO - South SF
# also SFO - Millbrae: few miles, high fare
# can the model figure out the intercept on its own?
m.int <- lm(Fare ~ Miles + Airport, data=BART.fares) 
# intercept of 1.68. pretty close

# First Graph: just the data
setwd("C:/bart project/output")
if (writeYN) { png('Bart fare v distance.png') }
plot(BART.fares[!airport.mask, 'Miles'],BART.fares[!airport.mask, 'Fare'],
     col="blue", xlab = "Driving Distance Between Stations (Miles)", 
     ylab= "Fare (Dollars)", xlim=c(0, 52), ylim=c(0, 12),
     main="BART Fare vs. Distance between Stations")
points(BART.fares[airport.mask, 'Miles'],BART.fares[airport.mask, 'Fare'],
       col="orange")
legend(x="bottomright", legend=c('Begin/End at SFO', 'Other'), 
       col=c("orange", "blue"), pch=19)
if (writeYN) { dev.off() }

p <- qplot(y=BART.fares$Fare, x=BART.fares$Miles, col=airport.mask,
      xlab = "Driving Distance Between Stations (Miles)", 
      ylab= "Fare (Dollars)", xlim=c(0, 52), ylim=c(0, 12))
p + scale_colour_manual(values=c("blue", "orange"),
                      name="Legend",
                      breaks=c(F, T),
                      labels=c("SFO", "Other"))
# make points bigger, empty instead of filled in, move legend
# now add regression line(s)
if (writeYN) { png('Bart fare v distance fitted.png') }
plot(BART.fares[!airport.mask, 'Miles'], BART.fares[!airport.mask, 'Fare'],
     col="blue", xlab = "Driving Distance Between Stations (Miles)", 
     ylab="Fare (Dollars)", xlim=c(0, 52), ylim=c(0, 12),
     main="BART Fare vs. Distance between Stations")
points(BART.fares[airport.mask, 'Miles'],
       BART.fares[airport.mask, 'Fare'], col="orange")
legend(x="bottomright", legend=c('Begin/End at SFO', 'Other'), 
       col=c("orange", "blue"), pch=19)
abline(a=1.75, b=coef(ma)[1], col="blue")
abline(a=coef(ma)[2] + 1.75, b=coef(ma)[1], col="orange")
if (writeYN) { dev.off() }
# SFO outlier is Millbrae-SFO trip. Fare = 4.05

# Residuals
if (writeYN) { png('Residuals v X.png') }
plot(y=ma$residuals[!airport.mask], x=BART.fares$Miles[!airport.mask],
     col="blue", xlab = "Driving Distance Between Stations (Miles)",
     ylab="Residual", main="Residuals of Model")
points(y=ma$residuals[airport.mask], x=BART.fares$Miles[airport.mask],
       col="orange")
if (writeYN) { dev.off() }

fareBART <- function(miles, SFO=FALSE) {
  # coefficients are from lm object 'ma'
  return (1.75 + 0.1045*miles + SFO*4.50)
}