#------------------------------------------------------------------#
#
# Plot histograms of Code Contributions (from git log data)
#
#------------------------------------------------------------------#
# Author: Philipp Staender (philipp.staender@rwth-aachen.de)       #
#------------------------------------------------------------------#

## 1. Prepare / clear environment and load modules ####
ls()
rm(list=ls(all=TRUE))
getwd()
setwd("~/mastersthesis/")
# include basic user defined methods
source('r/include.R')

source('r/include_filtered_repositories.R')   # repositories will be available as global `repositories`
source('r/include_filtered_organizations.R')  # org will be available as global `organizations`
source('r/include_firm_employed_developers_on_github.R')

# is needed for date conversion
Sys.setlocale("LC_TIME", "C")

## 2.1 Read all commits from CSV (takes a while)

allCommits <- read.csv('data/csv/calculated/optional/all_commits.csv', header = T, stringsAsFactors = F)
allCommits$timeZoneHour <- as.integer(gsub("^.*([-\\+][0-9]{1,2})([0-9]{2})$","\\1",allCommits$date_string))
additionalCommitData <- read.csv('data/csv/calculated/optional/additional_commit_data.csv', header = T, stringsAsFactors = F)
library(ggplot2)
theme_set(theme_gray(base_size = 18))

allCommits$`Firm Developer` <- 'no'
allCommits[allCommits$is_firm_employed == T, ]$`Firm Developer` <- 'yes'

## 3.1 Plot Time of Contributions (world time)

ggplot(data=allCommits, aes(allCommits$hour_of_commit, fill=`Firm Developer`)) + 
  stat_density(alpha=.7, adjust=2) +
  labs(x="Hour of Daytime", y="")

## 3.2 Plot Time of Contributions (locale time)
ggplot(data=allCommits, aes(allCommits$hour_of_commit_local, fill=`Firm Developer`)) + 
  stat_density(alpha=.7, adjust=2) +
  labs(x="Hour of Daytime", y="")

h <- hist(allCommits[allCommits$is_firm_employed == T, ]$hour_of_commit, breaks=24, col="red", xlab="Hour of daytime (code contribution)", main="Histogram with Normal Curve") 
h <- hist(allCommits[allCommits$is_firm_employed == T, ]$hour_of_commit_local, breaks=24, col="red", xlab="Hour of daytime (code contribution)", main="Histogram with Normal Curve") 

## 3.3 Plot Code on Contributions (which month)

allCommits$month <- as.character(gsub("^[a-zA-Z]+\\s([a-zA-Z]+?)\\s.*$", "\\1", allCommits$date))
allCommits[allCommits$month == 'Jan',]$month <- 1
allCommits[allCommits$month == 'Feb',]$month <- 2
allCommits[allCommits$month == 'Mar',]$month <- 3
allCommits[allCommits$month == 'Apr',]$month <- 4
allCommits[allCommits$month == 'May',]$month <- 5
allCommits[allCommits$month == 'Jun',]$month <- 6
allCommits[allCommits$month == 'Jul',]$month <- 7
allCommits[allCommits$month == 'Aug',]$month <- 8
allCommits[allCommits$month == 'Sep',]$month <- 9
allCommits[allCommits$month == 'Oct',]$month <- 10
allCommits[allCommits$month == 'Nov',]$month <- 11
allCommits[allCommits$month == 'Dec',]$month <- 12
allCommits$month <- as.integer(allCommits$month)

ggplot(data=allCommits, aes(allCommits$month, fill=`Firm Developer`)) + 
  stat_density(alpha=.7, adjust=4) +
  labs(x="Month", y="") +
  scale_x_discrete(limits=1:12)

ggplot(data=allCommits, aes(allCommits$timeZoneHour, fill=`Firm Developer`)) + 
  stat_density(alpha=.7, adjust=4) +
  # labs(title="Histogram for Month (of code contribution)") +
  labs(x="Time Zone", y="")
  # scale_x_discrete(limits=1:12)

