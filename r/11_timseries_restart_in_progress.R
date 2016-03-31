#------------------------------------------------------------------#
#
# Graphical representation of code contribution over time
# by firm employed (int) and external (ext) developer 
#
#------------------------------------------------------------------#
# Author: Philipp Staender (philipp.staender@rwth-aachen.de)       #
#------------------------------------------------------------------#

## 1. Reset Environment and define basic settings #####
ls()
rm(list=ls(all=TRUE))
getwd()
setwd("/Users/philipp/masterthesis/")
library(RColorBrewer)
customLines = c(1, 1)
customColors = c('#222222', '#FFC748')
require(xts)
require(PerformanceAnalytics)
library(plyr)

outputAsPDF = pdfFilename = paste0("graphics/watch_forks_events") #.pdf will be attached later

lineWidth = 2


# This includes some helper methods (e.g. latex export, pdf export …)
source('r/include.R')
source('r/include_filtered_repositories.R')   # repositories will be available as global `repositories`
source('r/include_filtered_organizations.R')  # org will be available as global `organizations`
source('r/include_firm_employed_developers_on_github.R')
# source('r/include_dialog_input.R')

repoID <- c(5550552)
repo <- allOrganizationsRepos[allOrganizationsRepos$id == repoID, ]

organization <- organizations[organizations$login == repo$owner.login,]
organizationsEmailPattern <- toString(organization$email_domain)

fileFork <- paste0("data/csv/repositories/forkevent/forkevent_", repo$owner.login, "_", repo$name, ".csv")
fileEvent <- paste0("data/csv/repositories/watchevent/watchevent_", repo$owner.login, "_", repo$name, ".csv")

if (file.exists(fileFork) & (file.exists(fileEvent))){
  # print(fileFork)
  event <- read.csv(fileFork, header = T, stringsAsFactors = F)
  # print(fileEvent)
  event <- rbind(event, read.csv(fileEvent, header = T, stringsAsFactors = F))
}

event$is_firm_employed <- FALSE

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




### COMMITS ###




commitsOverTime <- read.csv(paste0("data/csv/repositories/logs/logs_", repo$owner.login, "_", repo$name, ".csv"), header = T, stringsAsFactors = F)
commitsOverTime = subset(commitsOverTime, nchar(commitsOverTime$date) < 60)
# convert date format
commitsOverTime$date = as.Date(as.character(commitsOverTime$date), format ='%a %b %d %Y %H:%M:%S GMT%z')
# remove N/A
commitsOverTime <- na.omit(commitsOverTime)




commits <- commitsOverTime
commits$valid_email <- as.logical(regexpr(regexValidEmail, commits$author.email, ignore.case = T) == 1)
# remove all commits with invalid email addresses from observation
for (excludePattern in excludeEmailPatterns) {
  commits <- subset(commits, commits$valid_email == T)
  commits$valid_email <- as.logical(regexpr(excludePattern, commits$author.email, ignore.case = T) == -1)
}
commits <- subset(commits, commits$valid_email == T)
# mark all firm employed developers defined by regex pattern in `commercial_classification_of_organizations.csv` for each organization
commits$is_firm_employed <- as.logical(regexpr(organizationsEmailPattern, commits$author.email, ignore.case = T) >= 0)
commits <- cbind(commits, is_firm_employed_manually = mapply(isUserFromFirm, commits$author.email, repo$owner.login, T))
commits[commits$is_firm_employed_manually == T, ]$is_firm_employed <- commits[commits$is_firm_employed_manually == T, ]$is_firm_employed_manually

commitsOverTime <- commits

#repo_id,repo_url,type,created_at,actor_id,actor_url,actor_login,id,event_type
commitsEvent <- commitsOverTime[,c(3,4,8)]
commitsEvent$repo_id <- as.numeric(repo$id)
commitsEvent$repo_url <- as.character(repo$name)
commitsEvent$type <- commitsEvent$event_type <- 'CommitEvent'
commitsEvent$id <- -1
commitsEvent$actor_id <- -1
commitsEvent$actor_login <- ''
commitsEvent$created_at <- commitsEvent$date
commitsEvent <- rename(commitsEvent, c("author.email"="actor_url"))


event <- rbind(event, commitsEvent)

# type,created_at,actor_id,actor_url,actor_login,id,event_type
# commitsEvemt
# if (! nrow(event) > 0) {
#   next
# }


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
event$CommitEvent <- xts(event$event_type == 'CommitEvent', event$date, frequency=timeFrequency)
observations <- data.frame(AllEvents = do.call(applyFrequenceFunction, list(event$ForkEvent | event$WatchEvent | event$CommitEvent, sum)))
observations$ForkEvent <- do.call(applyFrequenceFunction, list(event$ForkEvent, sum))
observations$WatchEvent <- do.call(applyFrequenceFunction, list(event$WatchEvent, sum))
observations$CommitEvent <- do.call(applyFrequenceFunction, list(event$CommitEvent, sum))

observationsCumulative <- cumsum(observations+1)-1
# observations$ForkEventCumulative <- observationsCumulative$ForkEvent * ( max(observations$ForkEvent) / max(observationsCumulative$ForkEvent) )
# observations$WatchEventCumulative <- observationsCumulative$WatchEvent * ( max(observations$WatchEvent) / max(observationsCumulative$WatchEvent) )
observations$ForkEventCumulative <- observationsCumulative$ForkEvent
observations$WatchEventCumulative <- observationsCumulative$WatchEvent
observations$CommitEventCumulative <- observationsCumulative$CommitEvent

observations$ForkEvent <- observations$ForkEvent * ( max(observationsCumulative$ForkEvent) / max(observations$ForkEvent) )
observations$WatchEvent <- observations$WatchEvent * ( max(observationsCumulative$WatchEvent) / max(observations$WatchEvent) )
observations$CommitEvent <- observations$CommitEvent * ( max(observationsCumulative$CommitEvent) / max(observations$CommitEvent) )




# collection <- cbind(observations$CommitEvent, observations$ForkEvent, observations$WatchEvent, observations$CommitEventCumulative, observations$ForkEventCumulative, observations$WatchEventCumulative)
# collection <- as.zoo(collection)
# #col = customColors
# plot(x = collection, ylab = "events", screens = 1, col = customColors, lwd=lineWidth, lty=customLines) #lty = "dotted", 
# simpleGridOverlay(0.05)
# legend(x = "topright", bty = "n", legend = c("Int", "Ext", "Fork", "Watch", "Fork cum.","Watch cum."), lty=customLines, lwd=lineWidth, col = customColors)
# title(
#   main=paste0(repo$organization_name,'/',repo$repository_name),
#   sub=paste0(
#     'top: ', as.integer(repo$is_top_repository),
#     '; age:', round(repo$age/365, 1),
#     '; watch.:', repo$subscribers_count,
#     '; stars.:', repo$stargazers_count,
#     '; forks:', repo$forks_count
#   )
# ) 



# 
# 
# ggplot(observations,aes())+geom_line(aes(color="forkevent"))+
#   geom_line(data=observations$ForkEventCumulative,aes(color="watchevent"))+
#   labs(color="Legend text")
