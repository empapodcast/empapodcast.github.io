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

    
    dates <- seq(start.date, end.date,1)
    dates <- paste(dates, 'T09:00:00', sep='')
    
    forecasts <- lapply(dates, function(x){
        out <- tryCatch(get_forecast_for(fremont.lat, fremont.lon, x),
                        error=function(e) NULL)
    })
    
    names(forecasts) <- dates
    return(forecasts)
}


##' Gets hourly weather data.
##'
##' Takes as input a list of data objects returned from the dark sky
##' api and extracts hourly data for each day.
##' @title
##' @param data List of data objects from get_forecast_for() function.
##'     Each element in list represents a day.
##' @return data.table object combining hourly data for all days.
##' @author Romel D. Mackelprang
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
    

    hourly[,decade:=substr(year, 3,3)]
    hourly[,decade:=factor(decade, levels=c(5,6,7,8,9,0,1),
                           labels=c('50s', '60s', '70s', '80s', '90s', '00s', '01s'))]


    return(hourly)

}
