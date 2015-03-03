library(stringr)
x <- data %>% mutate(., EuclidMiles = round(EuclidMiles, 2))  %>% t
for(i in 1:nrow(x)) {
 for(j in 1:ncol(x)) {
   x[i, j] <- paste("'", rownames(x)[i], "':", ifelse(i <= 2, "'", ""), str_trim(x[i, j]),
                    ifelse(i <= 2, "'", ""), ",", sep="")
 }
}
x[1, ] <- paste("{", x[1, ], sep="")
x[nrow(x), ] %<>% str_replace(., fixed(","), "},")
write.table(t(x), 'data/BART/crow flies distance json.txt', row.names=F, col.names=F, quote=F)
