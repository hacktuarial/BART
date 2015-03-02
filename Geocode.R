
#from http://statisfaction.wordpress.com/2011/10/05/calling-google-maps-api-from-r/
stations <- read.csv("F:/BART Project/data/bart/bart station names.csv")
stations <- unique(stations[, 1])
library(stringr)

getDocNodeVal=function(doc, path)
{
  sapply(getNodeSet(doc, path), function(el) xmlValue(el))
}

gGeoCode=function(str)
{
  library(XML)
  u=paste('http://maps.google.com/maps/api/geocode/xml?sensor=false&address=',str)
  doc = xmlTreeParse(u, useInternal=TRUE)
  str=gsub(' ','%20',str)
  lat=getDocNodeVal(doc, "/GeocodeResponse/result/geometry/location/lat")
  lng=getDocNodeVal(doc, "/GeocodeResponse/result/geometry/location/lng")
  list(lat = lat, lng = lng)
}

LL <- vector('list', length = 44) #Latitude Longitude
LL <- lapply(paste(stations, 'Station', sep=' '), gGeoCode)

names(LL) <- gsub(x=stations,pattern="BART",replacement="",fixed=T)

LL[[1]] <- gGeoCode("16th St. Mission BART Station, 16th Street, San Francisco, CA")
LL[[3]] <- gGeoCode("24th St. Mission BART Station, 16th Street, San Francisco, CA")
#need attention: Ashby, Balboa Park, Bay Fair, Colma, Downtown Berkeley, Dublin/Pleasanton,
# El Cerrito del Norte, El Cerrito Plaza, Montgomery St., Pleasant Hill/Contra Costa Centre,
# Powell St, South San Francisco, Walnut Creek, 12th st. oakland city center
LL[['Ashby ']] <- gGeoCode("3100 Adeline St, Berkeley, CA")
LL[['Balboa Park ']] <- list(lat=37.721981, lng=-122.447414)
LL[['Bay Fair  ']]   <- gGeoCode('Bay Fair BART Station, 15242 Hesperian Boulevard, San Leandro, CA 94578')
LL[['Castro Valley ']] <- list(lat=37.6908048, lng=-122.0756558)
LL[['Colma ']]       <- gGeoCode('365 D Street, Colma, CA 94014')
LL[['Concord ']]       <- gGeoCode('Concord BART, Concord, CA')
LL[['Downtown Berkeley ']] <- gGeoCode('2160 Shattuck Ave, Berkeley, CA')
LL[['Glen Park ']] <- list(lat=37.7206310, lng=-122.4468180)
LL[['Dublin/Pleasanton ']] <- list(lat = 37.701695, lng = -121.900367)
LL[['El Cerrito del Norte ']] <- list(lat = 37.925655, lng = -122.317269)
LL[['El Cerrito Plaza ']] <- list(lat = 37.903059, lng = -122.299272)
LL[['Lafayette ']] <- gGeoCode('Lafayette BART, Lafayette, CA')
LL[['Lake Merritt  ']] <- list(lat=37.7972889, lng=-122.2653151)
LL[['Montgomery St. ']]  <- gGeoCode('Montgomery St. Station, 598 Market Street, San Francisco, CA 94104')
LL[['Pleasant Hill/Contra Costa Centre ']] <- list(lat=37.928403, lng=-122.056013)
LL[['Powell St. ']] <- gGeoCode('Powell St. Station, Market Street, San Francisco, CA')
LL[['Rockridge  ']] <- gGeoCode('Rockridge BART, College Avenue, Oakland, CA')
LL[['San Bruno ']] <- gGeoCode('San Bruno BART, San Bruno, CA')
LL[['San Francisco Int\'l Airport ']] <- gGeoCode('San Francisco International Airport')
LL[['South San Francisco ']] <- gGeoCode('1333 Mission Road, South San Francisco, CA 94080')
LL[['Walnut Creek ']] <- gGeoCode('Bart Walnut Creek')
LL[['12th St. Oakland City Center ']] <- list(lat=37.803664, lng=-122.271604)
LL[['San Bruno  ']] <- NULL #typo
save.image("F:/BART project/BART geo.RData")
#load("F:/BART project/BART geo.RData")
#plot
y <- sapply(LL, function(x) {as.numeric(x$lat)})
x <- sapply(LL, function(x) {as.numeric(x$lng)})
plot(x, y, xlab="Longitude", ylab="Latitude", main="Location of BART Stations")
bay.line <- mean(as.numeric(c(LL[['Richmond ']]$lng, LL[['Embarcadero ']]$lng)))
abline(v = bay.line)

# for each station, label it as east or west of the bay
side_of_bay = ifelse(x < bay.line, "W", "E")
stations2 <- data.frame(stations, side_of_bay)
write.csv(x=stations2, row.names=F,
          file="F:/bart project/data/bart/stations side of bay.csv")