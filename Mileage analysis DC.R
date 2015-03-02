Greenbelt <- read.csv("C:/BART Project/DC Comparison/Fares from Greenbelt.csv")

plot(Miles~Peak_Fare, data=Greenbelt) # interesting!
# peak fare is capped at 5.75
# what is the fewest miles travelled for which fare = 5.75?
min(Greenbelt[Greenbelt$Peak_Fare == 5.75, 'Miles']) 
# Answer: 15.63
Greenbelt$Capped_Miles <- pmin(Greenbelt$Miles, 15.6)

# fit a model that excludes the capped fares

lm.peak <- lm(Peak_Fare ~ Miles,data=
                Greenbelt[Greenbelt$Peak_Fare < 5.75, ])
# fit is nearly perfect. fare = 1.37 + 0.28 * Miles
# outliers: 16, 59 which are the 2 stations closest to Greenbelt
mask <- Greenbelt$Peak_Fare < 5.75
mask[c(16, 59, 82)] <- FALSE
lm.peak2 <- lm(Peak_Fare ~ Miles,data=
                 Greenbelt[mask, ])
# residuals seem to be biased high for low Mile trips
# what if we force the intercept to be min(Peak_Fare)
Greenbelt$Peak_Fare_Shifted <- Greenbelt$Peak_Fare - 2.10
lm.peak3 <- lm(Peak_Fare_Shifted ~ 0 + Miles, data=Greenbelt[mask, ])
# 22.26 cents per mile. residuals pass shapiro test, but there is still a clear 
#  relationship between Miles and Residual

lm.peak2 <- lm(Peak_Fare ~ Capped_Miles, data=Greenbelt)
plot(Peak_Fare ~ Capped_Miles, data=Greenbelt, ylim=c(0, 6), xlim=c(0, 16))
# well, R2 is 0.9997. intercept = 1.36, beta = 0.2811
# qq plot looks funny because there are many points with residual == 0 because of cap
# outliers: 16, 59 which are the 2 stations closest to Greenbelt

lm.peak3 <- lm(Peak_Fare ~ Capped_Miles, data=Greenbelt[Greenbelt$Miles > 5, ])
# coefficients are 1.355 and 0.2815

# min(Greenbelt$Peak_Fare) is 2.10
lm.noint <- lm(I(Peak_Fare-2.1) ~ 0 + Miles, data=Greenbelt)
# R squared is .9825; beta=.2058. residuals look terrible

# off-peak fares
plot(Off_Peak_Fare ~ Miles, data=Greenbelt)
# what is the fewest miles travelled for which fare = 5.75?
min(Greenbelt[Greenbelt$Off_Peak_Fare == 3.50, 'Miles']) 
# Answer: 11.26

Greenbelt$Capped_Miles_Off_Peak <- pmin(Greenbelt$Miles, 11.25)
lm.off.peak2 <- lm(Off_Peak_Fare ~ Capped_Miles_Off_Peak, data=Greenbelt)

