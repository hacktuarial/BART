# This script analyzes the relationship between Miles Traveled
# and Fare (peak and off-peak) for the DC Metro System
# I assume trips to Metro Center are representative of the
# entire DC Metro System,
# and then test that assumption using trips from L'Enfant Plaza.
# I assume Fare is symmetric, so that traveling from Station A to 
# Station B costs the same as B to A.
# written by Timothy Sweetser, 2013. 
# http://sites.google.com/site/tsweetser
# I endeavored to follow these code style guidelines: 
# http://google-styleguide.googlecode.com/svn/trunk/Rguide.xml

library(car)
library(stats)
library(rpart)
writeYN <- FALSE
# setwd("//volumes/no name/bart project") # MAC
setwd("F:/bart project") # PC


Fares.MC <- read.csv("data/DC metro/Fares from Metro Center.csv")
Fares.MC <- Fares.MC[order(Fares.MC$Miles), ]


if (writeYN) {png('output/DC Metro fare v distance.png')}
plot(Peak_Fare~Miles, data=Fares.MC, ylim=c(0, 6),
     xlab="Miles from Metro Center Station", 
     ylab="Peak Fare (Dollars)", 
     main="DC Metro Fare vs. Distance from Metro Center",
     pch=2, col="blue")
points(Off_Peak_Fare~Miles, data=Fares.MC, pch=4, col="orange")
legend(x="bottomright", legend=c("Peak Fare", "Off-Peak Fare"), 
       col=c("blue", "orange"), pch=c(2, 4))
if (writeYN) { dev.off() }
# peak fare is capped at 5.75
# only one station seems to be there
# however, many are are the minimum fare of 2.10

peak.model1 <- lm(Peak_Fare~Miles, data=Fares.MC, subset=Fares.MC$Miles<3)
peak.model2 <- lm(Peak_Fare~Miles, data=Fares.MC, 
                  subset=Fares.MC$Miles>=3 & Fares.MC$Miles < 17)

if (writeYN) { png('DC Metro peak fare v distance fitted.png') }
plot(Peak_Fare~Miles, data=Fares.MC, ylim=c(0, 6),
     xlab="Miles from Metro Center Station", 
     ylab="Peak Fare (Dollars)", 
     main="DC Metro Peak Fare vs. Distance from Metro Center",
     pch=2, col="blue")
points(x=c(0, 3), y=rep.int(2.10, 2), type='l', col="red", lwd=2)
points(x=c(3, 15.5), y=c(coef(peak.model2)[1]+3*coef(peak.model2)[2], 
                         coef(peak.model2)[1]+15.5*coef(peak.model2)[2]),
       type='l',col="red", lwd=2)
points(x=c(15.5, 18), y=rep.int(5.75, 2), col="red", type='l', lwd=2)
legend(x="bottomright", legend=c("True Fare", "Fitted Fare"), 
       col=c("blue", "red"), pch=c(2, 19))
if (writeYN) { dev.off() }

# off-peak model
# use a tree
tree <- rpart(Off_Peak_Fare ~ Miles, data=Fares.MC)
tree.est <- predict(tree, Fares.MC)
if (writeYN) { png('output/DC Metro Offpeak Dec Tree.png') }
plot(Off_Peak_Fare ~ Miles, data=Fares.MC, pch=4, col="orange",
     ylim=c(0, 4), xlab="Miles from Metro Center", ylab="Off Peak Fare",
     main="Decision Tree Estimate")
points(Fares.MC$Miles, tree.est, type='l', lwd=2)
legend(x="bottomright",pch=c(4, 19), col=c("orange", "black"),
       legend=c("Actual", "Dec. Tree Estimate"))
if (writeYN) { dev.off() }

tree.res <- Fares.MC$Off_Peak_Fare - tree.est
plot(y=tree.res, x=Fares.MC$Miles)
# R2 is  99.43%
1 - sum(tree.res^2)/
  sum( (Fares.MC$Off_Peak_Fare - mean(Fares.MC$Off_Peak_Fare))^2 )

# most common values: 1.70, 2.05, 2.75, 3.50 (max)
mask <- Fares.MC$Off_Peak_Fare %in% c(1.70, 2.05, 2.75, 3.50)
lm.offpeak <- lm(Off_Peak_Fare ~ Miles, data=Fares.MC, subset=!mask)
if (writeYN) { png('output/DC Metro Offpeak Reg.png') }
plot(Off_Peak_Fare ~ Miles, data=Fares.MC, xlab="Miles from Metro Center", 
     ylab="Off Peak Fare", ylim=c(0, 4), col="orange", pch=4, 
     main="Regression between Steps")
points(x=Fares.MC$Miles, y=fareDC(Fares.MC$Miles, FALSE), type='l', lwd=2)
legend(x="bottomright",pch=c(4, 19), col=c("orange", "black"),
       legend=c("Actual", "Regression Estimate"))
if (writeYN) { dev.off() }
partlm.res <- Fares.MC$Off_Peak_Fare - fareDC(Fares.MC$Miles, FALSE)
# r squared is 99.98%
1 - sum(partlm.res^2)/sum( 
  (Fares.MC$Off_Peak_Fare - mean(Fares.MC$Off_Peak_Fare))^2 )

# consolidate these 2 models into one function
fareDC <- function(miles, peak=T) {
  # this function estimates the fare charged by the DC metro system
  # for traveling miles. 
  # peak pertains to time of day: 
  # opening - 9:30 am, 3 to 7 pm, and midnight until closing
  # all other times are "off-peak"
  # peak and off-peak fares follow different formulae
  
  ans <- rep.int(0, length(miles))
  if (peak) {
    ans <- pmax(2.10, pmin(5.75, 1.285 + 0.2882*miles))
    # coefficients are from peak.model2
  }
  # off-peak using the regression model
  if (!peak) {
    for (i in 1:length(miles)) {
      if (miles[i] <= 3.2) { ans[i] <- 1.70}
      else if (miles[i] > 4.45 & miles[i] < 6.3) { ans[i] <- 2.05 }
      else if (miles[i] > 7.50 & miles[i] < 9.6) { ans[i] <- 2.75 }
      else if (miles[i] > 11.4) { ans[i] <- 3.50 }
      else {ans[i] <- 1.05 + 0.221*miles[i]}
    } # close for loop
  } # close off-peak if statement
  return(ans)
}

# calculate residuals
peak.res <- Fares.MC$Peak_Fare - fareDC(Fares.MC$Miles)
if (writeYN) { png('output/DC Metro peak residuals.png') }
plot(x=Fares.MC$Miles, y=peak.res, xlab="Miles from Metro Center",
     ylab="Residual", main="Residuals vs Fitted")
if (writeYN) { dev.off() }
# R^2 is 99.96%
1 - sum(peak.res^2)/sum( (Fares.MC$Peak_Fare - mean(Fares.MC$Peak_Fare))^2 )


# have we overfit? evaluate predictions for l'enfant plaza station
Fares.Lenfant <- read.csv("data/DC metro/Fares from Lenfant.csv")
# peak R2 is 99.28%
lenfant.peak.res <- Fares.Lenfant$Peak_Fare - 
    fareDC(Fares.Lenfant$Miles, peak=T)
1 - sum(lenfant.peak.res^2)/sum( 
  (Fares.Lenfant$Peak_Fare - mean(Fares.Lenfant$Peak_Fare))^2 )
# off peak R2 is 92.16%
lenfant.offpeak.res <- Fares.Lenfant$Off_Peak_Fare - 
  fareDC(Fares.Lenfant$Miles, peak=F)
1 - sum(lenfant.offpeak.res^2)/sum( 
  (Fares.Lenfant$Off_Peak_Fare - mean(Fares.Lenfant$Off_Peak_Fare))^2 )

# with dec tree, off peak R2 is 91.7%
lenfant.offpeak.res <- Fares.Lenfant$Off_Peak_Fare - 
  predict(tree, Fares.Lenfant)
1 - sum(lenfant.offpeak.res^2)/sum( 
  (Fares.Lenfant$Off_Peak_Fare - mean(Fares.Lenfant$Off_Peak_Fare))^2 )


# Finally, do a comparison of BART and DC by mileage
# bart goes 52 miles, DC only up to 25 (Greenbelt to Franconia/Springfield)
# but Dulles
t <- seq(1, 30, by=0.1)
# I changed the lwd parameter, but in the png or jpeg file,
# it was as if lwd=1 no matter how I set it here. Use points instead
par(pch=19)
if (writeYN) { png('F:/bart project/output/Comparison DC BART.png') }
plot(t, fareDC(t, TRUE), col="blue", pch=19, 
     ylim=c(0, 7), ylab="Fare", xlab="Miles", xlim=c(0, 40),
     main="Which System is More Expensive?")
points(t, fareDC(t, FALSE), col=rgb(84, 88, 90, maxColorValue=255)) 
points(seq(1, 40, by=0.1), fareBART(seq(1, 40, 0.1), FALSE), col="orange")
legend(col=c("blue", rgb(84, 88, 90, maxColorValue=255), "orange"),
  legend=c("DC Peak", "DC Off-Peak", "BART (x-SFO)"),
  x="bottomright", pch=19)      
if (writeYN) { dev.off() }

data.frame(miles=t, DCpeak=fareDC(t, TRUE), 
           DCoffpeak=fareDC(t, FALSE), BART=fareBART(t, FALSE))

# do an "airport" run: Dulles and SFO
#  completely uncapped
if (writeYN) { png('F:/bart project/output/Comparison Airport.png') }
plot(t, pmax(2.10, 1.285 + 0.2882*t), col="blue", 
     ylab="Fare", xlab="Miles", xlim=c(0, 40), ylim=c(0, 12),
     main="Where is it cheaper to get to the airport?")
points(t, 1.05 + 0.221*t, col=rgb(84, 88, 90, maxColorValue=255))
points(seq(1, 40, by=0.1), fareBART(seq(1, 40, 0.1), TRUE), col="orange")
legend(col=c("blue", rgb(84, 88, 90, maxColorValue=255), "orange"),
       legend=c("DC Peak No Cap", "DC Off-Peak No Cap", "BART to SFO"),
       x="bottomright", pch=19)
if (writeYN) { dev.off() }