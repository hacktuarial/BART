library(stringr)
load("C:/bart project/geo.RData")
D <- read.csv("C:/BART Project/reg input.csv")
names(LL) <- str_trim(names(LL))

#rearrange order of LL to match D
LL2 <- vector('list')
for(i in 2:44) {LL2[[i]] <- LL[i-1]}
LL2[[1]] <- LL[44]
names(LL2) <- c(names(LL)[44], names(LL)[1:43])
data.frame(unique(D$From), names(LL2))
LL <- LL2
rm(LL2)


data <- read.csv("C:/BART Project/reg input.csv")
data$Fare175 <- data$Fare - 1.75
data$Airport <- as.factor(data$Airport)
data$Self <- as.factor(data$Self) #all zeros, by design


#include each pair only once
keepers <- NULL
for(i in 1: nrow(data)) {
  sister.row <- intersect(which(data$To == data$From[i]),
                      which(data$From == data$To[i]))
  keepers <- c(keepers,min(i,sister.row,na.rm=T))
}
nodups <- data[unique(keepers), ]
l <- split(nodups,nodups$Airport)


m <- lm(Fare175 ~ 0 + Miles,data=nodups)
ma <- lm(Fare175 ~ 0 + Miles + Airport,data=nodups)
anova(m,ma) # p value < .05: reject the null, keep Airport in the model


plot(l[["0"]]$Miles,l[["0"]]$Fare175,col="blue",
     xlab = "Miles Traveled", ylab= "Fare")
points(x=l[["1"]]$Miles,y=l[["1"]]$Fare175,col="orange")
abline(ma)

identify(nodups$Miles,nodups$Fare175)
airport.mask <- nodups$Airport == 1
m.noair <- lm(Fare175 ~ 0 + Miles,data=nodups[!airport.mask,])
m.air   <- lm(Fare175 ~ 0 + Miles,data=nodups[airport.mask,])

identify(nodups$Miles[airport.mask],nodups$Fare175[airport.mask])


#outliers: 911 San Bruno - SFO, 921 SFO - South SF
#also SFO - Millbrae: few miles, high fare