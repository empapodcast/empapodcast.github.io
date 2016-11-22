file='SeattleWeatherData.rmd'

name=gsub('.rmd', '', file)
name=paste(Sys.Date(), '-', name, sep='')
out.file=paste(name, '.md',sep='')
fig.file=paste(name, '-figures/',sep='')

knitr::opts_knit$set(base.url = "/")
knitr::opts_chunk$set(fig.path = fig.file)




content <- readLines(file)

knitr::knit(text=content, output=out.file)

file.copy(from=out.file, to='../_posts', overwrite=TRUE)
file.copy(from=fig.file, to='../images', recursive=TRUE, overwrite=TRUE)

file.remove(out.file)
file.remove(fig.file, recursive=TRUE)
