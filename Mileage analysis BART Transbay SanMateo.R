# This script reads in a data file containing driving distances and 
# fares between every pair of stations
# served by Bay Area Rapid Transit, as of January 1, 2013. 
# Self and Airport are indicator variables
# Self = 1 if and only if From Station = To Station
# Airport = 1 if and only if San Francisco International Airport 
# is the To or From Station
# I assume Fare is symmetric, so that traveling from Station A to 
# Station B costs the same as B to A
# SanMateo == 1 iff the trip is To or From 
# Daly City, Colma, South San Francisco, San Bruno or Millbrae
# SFO airport might be in San Mateo county,
# but I already have a surcharge built in for SFO trips
# written by Timothy Sweetser, 2013. 
# http://sites.google.com/site/tsweetser

writeYN <- FALSE
# setwd('F:/BART Project')
setwd('//volumes/no name/BART project')
BART.raw <- read.csv(
  # "F:/BART Project/data/bart/BART all possible trips.csv") # PC
  "data/bart/BART all possible trips.csv")
source("distance correct.R")
BART.raw <- dist_correct(BART.raw)

# include each trip (one pair of stations) only once
keepers <- NULL
for (i in 1: nrow(BART.raw)) {
  sister.row <- intersect(which(BART.raw$To == BART.raw$From[i]),
                      which(BART.raw$From == BART.raw$To[i]))
  keepers <- c(keepers,min(i,sister.row,na.rm=T))
}
rm(i)
BART.fares <- BART.raw[unique(keepers), ]

# fit a linear regression model
mat <- lm(Fare ~ 0 + Miles2 + Airport*TransBay + SanMateo*TransBay, 
          # Airport:SanMateo is all 1's
          data=BART.fares,
          offset=rep(1.75,nrow(BART.fares)))
# none of these interaction terms are significant at 5%: Miles2:TransBay,
# Miles2:Airport, Miles2:SanMateo
# this means the per-mile rate is the same throughout the system
# the Millbrae-SFO trip has an extremely lg neg residual
# how much do the coefficients change by excluding it?
summary(lm(Fare ~ 0 + Miles2 + Airport*TransBay + SanMateo*TransBay, 
           data=BART.fares, offset=rep(1.75,nrow(BART.fares)),
           subset=BART.fares$Station.Pair.ID != 1110))
# Aiport increases from 4.84 to 5.09
# Airport:TransBay decreases from -0.84 to -1.09

# use this mask to color-code trips
transbay.mask <- BART.fares$TransBay == 1 
airport.mask <- BART.fares$Airport == 1

plot(x=BART.fares$Miles2, y=mat$residuals)
identify(x=BART.fares$Miles2, y=mat$residuals)
# outliers: 911 San Bruno - SFO, 921 SFO - South SF
# also SFO - Millbrae: few miles, high fare
# can the model figure out the intercept on its own?
m.int <- lm(Fare ~ Miles + Airport + TransBay, data=BART.fares) 
# intercept of 1.64. pretty close

setwd("F:/bart project/output")
# First Graph: just the data
if (writeYN) { png('Bart fare v distance TB.png') }
# non airport, non transbay
plot(BART.fares[!transbay.mask & !airport.mask, 'Miles'],
     BART.fares[!transbay.mask & !airport.mask, 'Fare'],
     col="blue", xlab = "Driving Distance Between Stations (Miles)", 
     ylab= "Fare (Dollars)", xlim=c(0, 52), ylim=c(0, 12),
     main="BART Fare vs. Distance between Stations", pch=0)
# non-airport, transbay
points(BART.fares[transbay.mask & !airport.mask, 'Miles'],
       BART.fares[transbay.mask & !airport.mask, 'Fare'],
       col="orange", pch=0)
# airport, non transbay
points(BART.fares[!transbay.mask & airport.mask, 'Miles'],
       BART.fares[!transbay.mask & airport.mask, 'Fare'],
       col="blue", pch=17)
# airport, transbay
points(BART.fares[transbay.mask & airport.mask, 'Miles'],
       BART.fares[transbay.mask & airport.mask, 'Fare'],
       col="orange", pch=17)
 # blue = non-transbay, orange=transbay
# pch0=square = non-airport. pch17=triangle=airport
legend(x="bottomright", legend=c('No Tube No SFO', 
                                 'Cross Bay noSFO',
                                 'SFO-Peninsula',
                                 'SFO-East Bay'), 
       col=rep(c("blue", "orange"), 2), pch=c(0, 0, 17, 17))
if (writeYN) { dev.off() }

# now add regression lines

if (writeYN) { png('Bart fare v distance fitted TB.png') }
plot(BART.fares[!transbay.mask & !airport.mask, 'Miles'],
     BART.fares[!transbay.mask & !airport.mask, 'Fare'],
     col="blue", xlab = "Driving Distance Between Stations (Miles)", 
     ylab= "Fare (Dollars)", xlim=c(0, 52), ylim=c(0, 12),
     main="BART Fare vs. Distance between Stations", pch=0)
# non-airport, transbay
points(BART.fares[transbay.mask & !airport.mask, 'Miles'],
       BART.fares[transbay.mask & !airport.mask, 'Fare'],
       col="orange", pch=0)
# airport, non transbay
points(BART.fares[!transbay.mask & airport.mask, 'Miles'],
       BART.fares[!transbay.mask & airport.mask, 'Fare'],
       col="blue", pch=17)
# airport, transbay
points(BART.fares[transbay.mask & airport.mask, 'Miles'],
       BART.fares[transbay.mask & airport.mask, 'Fare'],
       col="orange", pch=17)
# blue = non-transbay, orange=transbay
# pch0=square = non-airport. pch17=triangle=airport
legend(x="bottomright", legend=c('No Tube No SFO', 
                                 'Cross Bay noSFO',
                                 'SFO-Peninsula',
                                 'SFO-East Bay'), 
       col=rep(c("blue", "orange"), 2), pch=c(0, 0, 17, 17))

abline(a=1.75, b=coef(mat)[1], lwd=2, col="blue") # no tube, no airport
abline(a=coef(mat)[3] + 1.75, b=coef(mat)[1], lwd=2, 
       col="orange") #tube, no airport
abline(a=coef(mat)[2] + 1.75, b=coef(mat)[1], lwd=2,
       col="blue") #no tube, airport
abline(a=sum(coef(mat)[2:4]) + 1.75, b=coef(mat)[1], lwd=2,
       col="orange") #tube, airport
if (writeYN) { dev.off() }
# SFO outlier is Millbrae-SFO trip. Fare = 4.05

# Residuals
# Airport-only model
par(mfrow=c(2, 2))
plot(mat)
par(mfrow=c(1, 1))

if (writeYN) { png('BART Residuals v X TB.png') }
plot(y=mat$residuals, x=BART.fares$Miles,
      xlab = "Driving Distance Between Stations (Miles)",
     ylab="Residual", main="Residuals of Model")
if (writeYN) { dev.off() }


# look at mean residual by station
boxplot(sapply(split(c(mat$residual, mat$residual), 
             c(BART.fares$To, BART.fares$From)), mean))
lapply(split(c(mat$residual, mat$residual), 
             c(BART.fares$To, BART.fares$From)), length)
# Millbrae has an average residual of +52 cents!

fareBART <- function(miles, SFO=FALSE) {
  # coefficients are from lm object 'ma'
  return (1.75 + 0.1045*miles + SFO*4.50)
}