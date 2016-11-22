
### Get latest copy of darksky package from github
### (https://github.com/hrbrmstr/darksky)
#devtools::install_github("hrbrmstr/darksky")

fremont.lat <- 47.6475338
fremont.lon <- -122.34974740000001



##' Get historical weather data
##'
##' Uses the Dark Sky API to get historical weather for a specified
##' date range.  User specifies the latitude and longtitude.
##' @title Dark Sky data
##' @param start.date Starting date for weather formatte as a Date
##'     object.
##' @param end.date Starting date for weather formatte as a Date
##'     object.
##' @param lat Location latitude
##' @param lon Location longitude
##' @return 
##' @author Romel D. Mackelprang
get.ds.data <- function(start.date=as.Date('1950-01-01'),
                        end.date=as.Date('2016-11-16'),
                        lat=fremont.lat,
                        lon=fremont.lon){

    require(darksky)
    require(purrr)

    ## Set API key
    Sys.setenv(darksky_api_key='810a8d95ed11fc11ec7c6a0bf275307d')
                        
    dates <- seq(start.date, end.date,1)
    dates <- paste(dates, 'T09:00:00', sep='')
    
    forecasts <- lapply(dates, function(x){
        out <- tryCatch(get_forecast_for(fremont.lat, fremont.lon, x),
                        error=function(e) NULL)
    })
    names(forecasts) <- dates
    return(forecasts)
}



all.years <- seq(1950, 2016, 1)

## lapply(all.years, function(x){
##     s.d <- as.Date(paste(x, '-01-01', sep=''))
##     e.d <- as.Date(paste(x, '-12-31', sep=''))
##     print(s.d)
##     out <- get.ds.data(start.date=s.d, end.date=e.d)
##     save(out, file=paste('./DataIntermediate/Darksky/Darksky_',x,'.Rdata', sep=''))
##     return(NULL)
## })





hourly.ds <- function(data=ds1){

    require(data.table)

    ## Rbind to single dataframe.  Not all variables are available for
    ## each day so we use the rbind.fill() function from plyr
    hourly <- lapply(data, function(x){return(x$hourly)})
    hourly <- lapply(hourly, as.data.frame)
    hourly <- do.call(plyr::rbind.fill, hourly)
    hourly <- data.table(hourly)

    ## Separate date and time
    hourly[,date:=lubridate::date(time)]
    hourly[,year:=lubridate::year(time)]
    hourly[,hour:=lubridate::hour(time)]
    hourly[,month:=lubridate::month(time, label=TRUE)]

    return(hourly)

}

files <- list.files('./DataIntermediate/Darksky/', full.names=TRUE)
all.hourly <- lapply(files, function(x){
    load(x)
    return(hourly.ds(out))
})
all.hourly <- do.call(plyr::rbind.fill, all.hourly)
all.hourly <- data.table(all.hourly)

day <- all.hourly[,.(mean.temp = mean(temperature, na.rm=TRUE),
               max.temp=max(temperature, na.rm=TRUE),
               min.temp=min(temperature, na.rm=TRUE),
               sd.temp=sd(temperature, na.rm=TRUE)),
               by=date]

day[,day.year:=yday(date)]
day[,year:=year(date)]
day[,month:=month(date)]

require(ggplot2)
p <- ggplot(day, aes(x=day.year, y=mean.temp, group=year, colour=year)) +
    geom_smooth(se=FALSE) +
    scale_colour_gradient(low='blue', high='red') +
    theme_bw() +
    labs(
        title='Mean daily temperature in Seattle, 1950-2016',
        x='Day of calendar year', y='Temperature (F)')

p


month <- all.hourly[,.(mean.temp = mean(temperature, na.rm=TRUE),
                       max.temp=max(temperature, na.rm=TRUE),
                       min.temp=min(temperature, na.rm=TRUE),
                       sd.temp=sd(temperature, na.rm=TRUE)),
                    by=c('month', 'year')]

p <- ggplot(month, aes(x=year, y=mean.temp, group=month, colour=month)) +
    geom_smooth(se=FALSE) +
    theme_bw() +
    labs(
        title='Mean monthly temperature in Seattle, by year',
        x='Year', y='Temperature (F)')

p


p <- ggplot(month, aes(x=year, y=min.temp, group=month, colour=month)) +
    geom_smooth(se=FALSE) +
    theme_bw() +
    labs(
        title='Max monthly temperature in Seattle, by year',
        x='Year', y='Temperature (F)')

p

