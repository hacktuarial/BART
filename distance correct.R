dist_correct <- function(df) {
  # this function reads in BART.fares dataframe
  # for TransBay trips, it recalculates the distance
  # as the distance from station A to Embarcadero
  # plus the distance from Embarcadero to Station B
  
  # It should also correct for trips from the end of the Dublin/Pleasanton
  # line [Dublin/Pleasanton, West Dublin]
  # to the end of the Pittsburgh/Bay Point line
  # [Pittsburg/Bay Pt, North Concord, Concord, Pleasant Hill, Walnut Creek]
  
  oneside <- df[df$TransBay == 0, ]
  cross <- df[df$TransBay == 1, ]
  # leave oneside as it is
  cross$Miles2 <- 0
  for (i in 1:nrow(cross)) {
    while(cross[i, 'From'] == 'Embarcadero' | 
            cross[i, 'To'] == 'Embarcadero') {
      cross[i, 'Miles2'] <- cross[i, 'Miles']
      i <- i + 1
    }
    cross[i, 'Miles2'] <- df[df$From == cross[i, 'From'] & 
                    df$To == 'Embarcadero', 'Miles'] + 
      df[df$From == 'Embarcadero' & 
           df$To == cross[i, 'To'], 'Miles']
  }
  oneside$Miles2 <- oneside$Miles
  df <- rbind(oneside, cross)
  
  # do the same kind of thing for the following stations:
  stations.I680 <- list()
  stations.I680[['north']] <- c('Pittsburg/Bay Pt', 'North Concord', 
                         'Concord', 'Pleasant Hill', 'Walnut Creek',
                                'Lafayette')
  stations.I680[['south']] <- c('Dublin/Pleasanton', 'West Dublin')
  # look at trips between these stations
  trips.I680 <- rbind(df[df$To %in% stations.I680[['north']] &
                     df$From %in% stations.I680[['south']], ],
                      df[df$To %in% stations.I680[['south']] &
                           df$From %in% stations.I680[['north']], ])
  # transfer station for these trips is West Oakland
  trips.I680$Miles2 <- 0
  for (i in 1:nrow(trips.I680)) {
    # no need for a while-loop: West Oakland is not in stations.I680
    trips.I680[i, 'Miles2'] <- df[df$From == trips.I680[i, 'From'] & 
                               df$To == 'West Oakland', 'Miles'] + 
      df[df$From == 'West Oakland' & 
           df$To == trips.I680[i, 'To'], 'Miles']
  }
  return(rbind(df[!(df$Station.Pair.ID  %in% trips.I680$Station.Pair.ID), ],
               trips.I680))
}