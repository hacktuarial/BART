# This script reads in a data file containing driving distances and 
# fares between every pair of stations
# served by Bay Area Rapid Transit, as of January 1, 2014. 

# Airport == 1 if and only if San Francisco International Airport 
# is the To or From Station
# SanMateo == 1 iff the trip is To or From 
# Daly City, Colma, South San Francisco, San Bruno or Millbrae
# SFO airport might be in San Mateo county,
# but I already have a surcharge built in for SFO trips
# written by Timothy Sweetser, 2014. 
# http://sites.google.com/site/tsweetser

writeYN <- FALSE
setwd('//volumes/thumbie/BART project')
library(sqldf)

# read in data
distance <- read.csv("data/bart/Euclidean miles.csv")
fare_attributes <- read.csv("google_transit_2/fare_attributes.txt")
fare_rules <- read.csv("google_transit_2/fare_rules.txt")
stops <- read.csv("google_transit_2/stops.txt")

fares <- merge(fare_attributes, fare_rules, by = "fare_id")

# add side of bay to fares
# Richmond is the western-most station in the East Bay
# Embarcadero is the eastern-most station in the West Bay
bay.line <- mean(stops[stops$stop_id %in% c("RICH", "EMBR"), 'stop_lon'])
# add "side of bay" for origin and destination stations
fares <- sqldf("select f.*, s.stop_lon AS orig_lon FROM fares f, stops s WHERE f.origin_id = s.stop_id")
fares <- sqldf("select f.*, s.stop_lon AS dest_lon FROM fares f, stops s WHERE f.destination_id = s.stop_id")

data <- sqldf("SELECT x.*, y.price FROM distance x, fares y WHERE x.Orig = y.origin_id AND x.Dest = y.destination_id")

rm(list=c('distance', 'fares', 'fare_attributes', 'fare_rules')) # housekeeping



# TransBay dummy variable
fares$Transbay <- sign( (fares$orig_lon - bay.line) * (fares$dest_lon - bay.line)) == -1

# remove trips starting and beginning at the same station
data <- data[data$Orig != data$Dest, c('Dest', 'Orig', 'EuclidMiles', 'price')]

# Create dummy variables
data$Airport <- as.numeric(data$Orig == 'SFIA' | data$Dest == 'SFIA')
SanMateo <- c('Daly City', 'Colma', 'South SF', 'San Bruno', 'Millbrae')
data$SanMateo <- as.numeric(data$To %in% SanMateo | data$From %in% SanMateo)

# TransBay dummy variable 


bayside <- read.csv("data/BART/stations side of bay.csv")
BART.fares <- merge(x=BART.fares, y=bayside, by.x='From', 
                    by.y='stations')
names(BART.fares)[ncol(BART.fares)] <- "From_Side"
BART.fares <- merge(x=BART.fares, y=bayside, by.x='To', 
                    by.y='stations')
names(BART.fares)[ncol(BART.fares)] <- "To_Side"
BART.fares$TransBay <- as.numeric(BART.fares$To_Side != 
                                    BART.fares$From_Side)

# fit a linear regression model
mat <- lm(Fare ~ 0 + Miles + Airport*TransBay + SanMateo*TransBay, 
          data=BART.fares, offset=rep(1.75,nrow(BART.fares)))
# none of these interaction terms are significant at 5%: Miles2:TransBay,
# Miles2:Airport, Miles2:SanMateo
# this means the per-mile rate is the same throughout the system
# the Millbrae-SFO trip has an extremely lg neg residual
# how much do the coefficients change by excluding it?
summary(lm(Fare ~ 0 + Miles + Airport*TransBay + SanMateo*TransBay, 
           data=BART.fares, offset=rep(1.75,nrow(BART.fares)),
           subset=c(rep(TRUE, 831), FALSE, rep(TRUE, 946-832))))
# Aiport increases from 4.43 to 4.70
# Airport:TransBay decreases from -0.73 to -1.00
# SanMateo increased from 0.80 to 0.84

# How many trips to SFO are from Millbrae?

# Compare SFO - Millbrae (row 832) to SFO - San Bruno (811)
# similar miles, but $3 fare difference!

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