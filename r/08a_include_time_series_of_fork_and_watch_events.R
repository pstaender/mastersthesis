
firmsRepos <- subset(allFirmsRepos, allFirmsRepos$is_top_project == isTopProject )
# only repos from relevant firms
firmsRepos <- firmsRepos[firmsRepos$owner.login %in% organizations$login, ]$id

if (is.character(outputAsPDF)) {
  if (isTRUE(isTopProject)) {
    outputAsPDF <- paste0(pdfFilename, '_top.pdf')
  } else {
    outputAsPDF <- paste0(pdfFilename, '_residual.pdf')
  }
}

countDone = 0

if (is.character(outputAsPDF)) {
  pdf(outputAsPDF, paper='A4r')#width=10, height=10)
  par(mfrow=c(2,2))
}

for (folder in firmsRepos$folder) {
  # display progrees
  countDone = countDone + 1
  print(paste0(countDone,"/",nrow(firmsRepos), "     (", round((100/nrow(firmsRepos))*countDone, 4), '%)    ', folder))
  
  # we have to extract the organization login and repo name from the filename :/
  organizationLogin = gsub('^(.*?)_(.*)$', '\\1', folder)
  repositoryName = gsub('^(.*?)_(.*)$', '\\2', folder)
  
  repo <- first(repositories[(repositories$repository_name == repositoryName) & (repositories$organization_name == organizationLogin), ])
  # skip repos and orgs that are not relevant for int/ext check
  if (! tolower(organizationLogin) %in% tolower(organizations$login)) {
    next
  }
  
  fileFork <- paste0('data/csv/repositories/forkevent/forkevent_', folder, '.csv')
  fileEvent <- paste0('data/csv/repositories/watchevent/watchevent_', folder, '.csv')
  
  if (file.exists(fileFork) & (file.exists(fileEvent))){
    # print(fileFork)
    event <- read.csv(fileFork, header = T, stringsAsFactors = F)
    # print(fileEvent)
    event <- rbind(event, read.csv(fileEvent, header = T, stringsAsFactors = F))
  }
  if (! nrow(event) > 0) {
    next
  }
  
  # TODO: add commits and issues / issues commenting
  # convert date; fix different date formats between 2011 - 2015
  # 2012-06-14T14:17:19-07:00
  event$date = as.Date(as.character(event$created_at))
  if (nrow(event[is.na(event$date),]) > 0) {
    event[is.na(event$date), ]$date <- as.Date(as.character(event[is.na(event$date), ]$created_at), format = "%Y/%m/%d %H:%M:%S %z")
  }
  if (nrow(event[is.na(event$date),]) > 0) {
    event[is.na(event$date), ]$date <- as.Date(as.character(event[is.na(event$date), ]$created_at), format = "%Y-%m-%dT%H:%M:%S")
  }
  diffInDays = max(event$date) - min(event$date)
  if (diffInDays < 370) {
    next
  }
  applyFrequence = 'weekly'
  #   if (diffInDays < 100) { applyFrequence = 'daily' }
  #   if (diffInDays > 1000) { applyFrequence = 'monthly' }
  applyFrequenceFunction = paste0("apply.", applyFrequence)
  timeFrequency = 12
  event$ForkEvent <- xts(event$event_type == 'ForkEvent', event$date, frequency=timeFrequency)
  event$WatchEvent <- xts(event$event_type == 'WatchEvent', event$date, frequency=timeFrequency)
  observations <- data.frame(AllEvents = do.call(applyFrequenceFunction, list(event$ForkEvent | event$WatchEvent, sum)))
  observations$ForkEvent <- do.call(applyFrequenceFunction, list(event$ForkEvent, sum))
  observations$WatchEvent <- do.call(applyFrequenceFunction, list(event$WatchEvent, sum))
  observationsCumulative <- cumsum(observations+1)-1
  # observations$ForkEventCumulative <- observationsCumulative$ForkEvent * ( max(observations$ForkEvent) / max(observationsCumulative$ForkEvent) )
  # observations$WatchEventCumulative <- observationsCumulative$WatchEvent * ( max(observations$WatchEvent) / max(observationsCumulative$WatchEvent) )
  observations$ForkEventCumulative <- observationsCumulative$ForkEvent
  observations$WatchEventCumulative <- observationsCumulative$WatchEvent
  observations$ForkEvent <- observations$ForkEvent * ( max(observationsCumulative$ForkEvent) / max(observations$ForkEvent) )
  observations$WatchEvent <- observations$WatchEvent * ( max(observationsCumulative$WatchEvent) / max(observations$WatchEvent) )
  
  # observations <- observationsComulated
  collection <- cbind(observations$ForkEvent, observations$WatchEvent, observations$ForkEventCumulative, observations$WatchEventCumulative)
  collection <- as.zoo(collection)
  plot(x = collection, ylab = "events", col = customColors, screens = 1, lwd=lineWidth, lty=customLines) #lty = "dotted", 
  simpleGridOverlay(0.05)
  legend(x = "topright", bty = "n", legend = c("Fork","Watch", "Fork cum.","Watch cum."), lty=customLines, lwd=lineWidth, col = customColors)
  title(
    main=paste0(repo$organization_name,'/',repo$repository_name),
    sub=paste0(
      'top: ', as.integer(repo$is_top_repository),
      '; age:', round(repo$age/365, 1),
      '; watch.:', repo$subscribers_count,
      '; stars.:', repo$stargazers_count,
      '; forks:', repo$forks_count
    )
  ) 
}

if (is.character(outputAsPDF)) {
  dev.off()
}
