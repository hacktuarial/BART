This script reads in a data file containing driving distances and fares between every pair of stations served by Bay Area Rapid Transit, as of January 1, 2013. Airport = 1 if and only if San Francisco International Airport is the To or From Station. I assume Fare is symmetric, so that traveling from Station A to Station B costs the same as B to A and has the same distance. SanMateo == 1 iff the trip is To or From Daly City, Colma, South San Francisco, San Bruno or Millbrae. SFO airport might be in San Mateo county, but I already have a surcharge built in for SFO trips.  
Written by Timothy Sweetser, last update April 2014.
https://sites.google.com/site/tsweetser

Read in raw data:

```r
setwd("//volumes/no name/BART project")
```

```
## Error: cannot change working directory
```

```r
fare_attributes <- read.csv("google_transit_2/fare_attributes.txt", header = T)
fare_rules <- read.csv("google_transit_2/fare_rules.txt", header = T)
fares <- merge(fare_attributes, fare_rules, by = "fare_id")
```

Since there are 44 stations, Fares has $1936 = 44^2$ rows.  
Read in miles between pairs of stations:

```r
distances <- read.csv("data/BART/Dijkstra miles.csv", header = T)
distances$key <- paste(distances$From, distances$To, sep = "")
fares$key <- paste(fares$origin_id, fares$destination_id, sep = "")
dataset <- merge(fares, distances, by = "key")
```

Remove trips starting and beginning at the same station.

```r
BART.raw <- BART.raw[BART.raw$From != BART.raw$To, ]
```

```
## Error: object 'BART.raw' not found
```

Airport and San Mateo dummy variables

```r
BART.raw$Airport <- as.numeric(BART.raw$To == "SFIA" | BART.raw$From == "SFIA")
```

```
## Error: object 'BART.raw' not found
```

```r
stations.SM <- c("Daly City", "Colma", "South SF", "San Bruno", "Millbrae")
BART.raw$SanMateo <- as.numeric(BART.raw$To %in% stations.SM | BART.raw$From %in% 
    stations.SM)
```

```
## Error: object 'BART.raw' not found
```

Include each trip (one pair of stations) only once

```r
keepers <- NULL
for (i in 1:nrow(BART.raw)) {
    sister.row <- intersect(which(BART.raw$To == BART.raw$From[i]), which(BART.raw$From == 
        BART.raw$To[i]))
    keepers <- c(keepers, min(i, sister.row, na.rm = T))
}
```

```
## Error: object 'BART.raw' not found
```

```r
BART.fares <- BART.raw[unique(keepers), ]
```

```
## Error: object 'BART.raw' not found
```

```r
rm(list = c("i", "keepers", "sister.row"))  # cleanup
```

```
## Warning: object 'i' not found
## Warning: object 'sister.row' not found
```

TransBay dummy variable 

```r
bayside <- read.csv("data/BART/stations side of bay.csv")
BART.fares <- merge(x = BART.fares, y = bayside, by.x = "From", by.y = "stations")
```

```
## Error: object 'BART.fares' not found
```

```r
names(BART.fares)[ncol(BART.fares)] <- "From_Side"
```

```
## Error: object 'BART.fares' not found
```

```r
BART.fares <- merge(x = BART.fares, y = bayside, by.x = "To", by.y = "stations")
```

```
## Error: object 'BART.fares' not found
```

```r
names(BART.fares)[ncol(BART.fares)] <- "To_Side"
```

```
## Error: object 'BART.fares' not found
```

```r
BART.fares$TransBay <- as.numeric(BART.fares$To_Side != BART.fares$From_Side)
```

```
## Error: object 'BART.fares' not found
```

Now, fit a linear regression model

```r
mat <- lm(Fare ~ 0 + Miles + Airport * TransBay + SanMateo * TransBay + Miles:TransBay + 
    Miles:Airport + Miles:SanMateo, data = BART.fares, offset = rep(1.75, nrow(BART.fares)))
```

```
## Error: object 'BART.fares' not found
```

```r
summary(mat)
```

```
## Error: object 'mat' not found
```

None of these interaction terms are significant at 5%: Miles:TransBay, Miles2:Airport, Miles2:SanMateo. This means the per-mile rate is the same throughout the system. The Millbrae-SFO trip has an extremely large, negative residual. How much do the coefficients change by excluding it?

```r
summary(lm(Fare ~ 0 + Miles + Airport * TransBay + SanMateo * TransBay, data = BART.fares, 
    offset = rep(1.75, nrow(BART.fares)), subset = c(rep(TRUE, 831), FALSE, 
        rep(TRUE, 946 - 832))))
```

```
## Error: object 'BART.fares' not found
```

Aiport increases from 4.43 to 4.70.  
Airport:TransBay decreases from -0.73 to -1.00.  
SanMateo increased from 0.80 to 0.84.  

Compare SFO - Millbrae (row 832) to SFO - San Bruno (811)
similar miles, but $3 fare difference!

Use this mask to color-code trips

```r
transbay.mask <- BART.fares$TransBay == 1
```

```
## Error: object 'BART.fares' not found
```

```r
airport.mask <- BART.fares$Airport == 1
```

```
## Error: object 'BART.fares' not found
```

```r

plot(x = BART.fares$Miles2, y = mat$residuals)
```

```
## Error: object 'BART.fares' not found
```


Outliers: 911 San Bruno - SFO, 921 SFO - South SF
Also SFO - Millbrae: few miles, high fare  

Can the model figure out the intercept on its own?

```r
m.int <- lm(Fare ~ Miles + Airport + TransBay, data = BART.fares)
```

```
## Error: object 'BART.fares' not found
```

Intercept of 1.64. pretty close

First Graph: just the data

```r
# non airport, non transbay
plot(BART.fares[!transbay.mask & !airport.mask, "Miles"], BART.fares[!transbay.mask & 
    !airport.mask, "Fare"], col = "blue", xlab = "Driving Distance Between Stations (Miles)", 
    ylab = "Fare (Dollars)", xlim = c(0, 52), ylim = c(0, 12), main = "BART Fare vs. Distance between Stations", 
    pch = 0)
```

```
## Error: object 'BART.fares' not found
```

```r
# non-airport, transbay
points(BART.fares[transbay.mask & !airport.mask, "Miles"], BART.fares[transbay.mask & 
    !airport.mask, "Fare"], col = "orange", pch = 0)
```

```
## Error: object 'BART.fares' not found
```

```r
# airport, non transbay
points(BART.fares[!transbay.mask & airport.mask, "Miles"], BART.fares[!transbay.mask & 
    airport.mask, "Fare"], col = "blue", pch = 17)
```

```
## Error: object 'BART.fares' not found
```

```r
# airport, transbay
points(BART.fares[transbay.mask & airport.mask, "Miles"], BART.fares[transbay.mask & 
    airport.mask, "Fare"], col = "orange", pch = 17)
```

```
## Error: object 'BART.fares' not found
```

```r
# blue = non-transbay, orange=transbay pch0=square = non-airport.
# pch17=triangle=airport
legend(x = "bottomright", legend = c("No Tube No SFO", "Cross Bay noSFO", "SFO-Peninsula", 
    "SFO-East Bay"), col = rep(c("blue", "orange"), 2), pch = c(0, 0, 17, 17))
```

```
## Error: plot.new has not been called yet
```

Now add regression lines.

```r
plot(BART.fares[!transbay.mask & !airport.mask, "Miles"], BART.fares[!transbay.mask & 
    !airport.mask, "Fare"], col = "blue", xlab = "Driving Distance Between Stations (Miles)", 
    ylab = "Fare (Dollars)", xlim = c(0, 52), ylim = c(0, 12), main = "BART Fare vs. Distance between Stations", 
    pch = 0)
```

```
## Error: object 'BART.fares' not found
```

```r
# non-airport, transbay
points(BART.fares[transbay.mask & !airport.mask, "Miles"], BART.fares[transbay.mask & 
    !airport.mask, "Fare"], col = "orange", pch = 0)
```

```
## Error: object 'BART.fares' not found
```

```r
# airport, non transbay
points(BART.fares[!transbay.mask & airport.mask, "Miles"], BART.fares[!transbay.mask & 
    airport.mask, "Fare"], col = "blue", pch = 17)
```

```
## Error: object 'BART.fares' not found
```

```r
# airport, transbay
points(BART.fares[transbay.mask & airport.mask, "Miles"], BART.fares[transbay.mask & 
    airport.mask, "Fare"], col = "orange", pch = 17)
```

```
## Error: object 'BART.fares' not found
```

```r
# blue = non-transbay, orange=transbay pch0=square = non-airport.
# pch17=triangle=airport
legend(x = "bottomright", legend = c("No Tube No SFO", "Cross Bay noSFO", "SFO-Peninsula", 
    "SFO-East Bay"), col = rep(c("blue", "orange"), 2), pch = c(0, 0, 17, 17))
```

```
## Error: plot.new has not been called yet
```

```r

abline(a = 1.75, b = coef(mat)[1], lwd = 2, col = "blue")  # no tube, no airport
```

```
## Error: object 'mat' not found
```

```r
abline(a = coef(mat)[3] + 1.75, b = coef(mat)[1], lwd = 2, col = "orange")  #tube, no airport
```

```
## Error: object 'mat' not found
```

```r
abline(a = coef(mat)[2] + 1.75, b = coef(mat)[1], lwd = 2, col = "blue")  #no tube, airport
```

```
## Error: object 'mat' not found
```

```r
abline(a = sum(coef(mat)[2:4]) + 1.75, b = coef(mat)[1], lwd = 2, col = "orange")  #tube, airport
```

```
## Error: object 'mat' not found
```

SFO outlier is Millbrae-SFO trip. Fare = 4.05

Residuals
Airport-only model

```r
par(mfrow = c(2, 2))
plot(mat)
```

```
## Error: object 'mat' not found
```

```r
par(mfrow = c(1, 1))


plot(y = mat$residuals, x = BART.fares$Miles, xlab = "Driving Distance Between Stations (Miles)", 
    ylab = "Residual", main = "Residuals of Model")
```

```
## Error: object 'BART.fares' not found
```



Look at mean residual by station.

```r
boxplot(sapply(split(c(mat$residual, mat$residual), c(BART.fares$To, BART.fares$From)), 
    mean))
```

```
## Error: object 'mat' not found
```

```r
lapply(split(c(mat$residual, mat$residual), c(BART.fares$To, BART.fares$From)), 
    length)
```

```
## Error: object 'mat' not found
```

Millbrae has an average residual of +52 cents!