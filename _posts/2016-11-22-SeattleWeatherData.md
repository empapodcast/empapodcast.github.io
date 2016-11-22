---
layout: post
title: "Trends in Seattle weather, 1950-2016"
description: Seattle weather trends, 1950-2016
headline: Historical Seattle Weather data
category: Seattle
tags: []
comments: false
mathjax:
---

In this post, I examine trends in Seattle weather from 1950-2016.  

# Historical weather data from Dark Sky

The historical weather data used in this analysis come from
[Dark Sky]{https://darksky.net}. This is a really cool data science
startup that started with the objective of using robots to make
weather predictions.  The Dark Sky API allows you to look up current
weather forecasts or historical weather data anywhere on the
globe. Wrapper libraries for multiple platforms have been developed
and are available at {https://darksky.net/dev/docs/libraries}.  These
can be used to integrate Dark Sky data into your app or service.  The
R wrapper library {https://github.com/hrbrmstr/darksky} has several
useful functions for accessing the API directly from R.

First we need to install the latest version of the R wrapper library
from GitHub.


```r
devtools::install_github("hrbrmstr/darksky")
```

To use the Dark Sky API, one simply needs to sign-up
{https://darksky.net/dev/} to recieve a secret key. Once you have a
secret key, you can set a global option for use in all the darksky
requests.


```r
Sys.setenv(darksky_api_key='StopPeekingAndGetYourOwnSecretKey')
```




## Getting the data

The main workhorse of the darksky package is the get_forecast_for()
function.  This function returns weather data for a specified
date-time at the geographic coordinates provided by the user.  For
historical data, it returns hourly, daily and current data for the
time specified. I wrote another wrapper function that extracts data
for multiple days and returns data as a data.table object.  This
function can be accessed at
{https://github.com/romelm/romelm.github.io/blob/master/SeattleWeatherData/Functions/DarkSkyFunctions.R}.

The Dark Sky API allows up to 1,000 free requests per
day and charges $0.0001 for each request over 1,000.  I downloaded
weather data all days between 1950 to November 16, 2016, which is over
1,000.  However, at $0.0001 per call, I was only charged $2.25.

To download those data, I used lapply() to extract data for each year.
I saved data for each year to be used later.


```r
source('./Functions/DarkSkyFunctions.R')

all.years <- seq(1950, 2016, 1)

lapply(all.years, function(x){
    s.d <- as.Date(paste(x, '-01-01', sep=''))
    e.d <- as.Date(paste(x, '-12-31', sep=''))
    print(s.d)
    out <- get.ds.data(start.date=s.d, end.date=e.d)
    save(out, file=paste('./DataIntermediate/Darksky/Darksky_',x,'.Rdata', sep=''))
    return(NULL)
})
```

# Hourly data

As described above, the data for each request to the API include
hourly and daily daily summaries in list format.  To extract the
hourly data from multiple days I used the following function:

Remember that I save a separate .Rdata file for each year.  Therefore,
I used the hourly.ds() function to load extract hourly data for all
years and combined those into a single data.table().


```r
source('./Functions/DarkSkyFunctions.R')
files <- list.files('./DataIntermediate/Darksky/', full.names=TRUE)
all.hourly <- lapply(files, function(x){
    load(x)
    return(hourly.ds(out))
})
all.hourly <- do.call(plyr::rbind.fill, all.hourly)
all.hourly <- data.table(all.hourly)
```



```r
require(ggplot2)
p <- ggplot(all.hourly[year==2016&month=='Oct',],
            aes(x=time, y=temperature, colour=hour)) +
    geom_point() + geom_line() + geom_smooth() +
    scale_colour_gradient(low='blue', high='red') +
    theme_bw() +
    labs(title='Mean daily temperature in Seattle, 1950-2016',
        x='Date', y='Temperature (F)')

p
```

```
## `geom_smooth()` using method = 'loess'
```

![plot of chunk HourlyTemperature](/2016-11-22-SeattleWeatherData-figures/HourlyTemperature-1.png)

```r
p <- ggplot(all.hourly[year==2016&month=='Oct',],
            aes(x=hour, y=temperature, colour=date, group=date)) +
    geom_line() + geom_smooth(se=FALSE) +
    theme_bw()
p
```

```
## `geom_smooth()` using method = 'loess'
```

![plot of chunk HourlyTemperature](/2016-11-22-SeattleWeatherData-figures/HourlyTemperature-2.png)

