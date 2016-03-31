#------------------------------------------------------------------#
#
# Classification in int + ext contributors
#
# This R scripts analyzes all commits of relevant organizations
#
#   * removes all commits from authors with invalid emails
#   * classsifies internal and external developers
#   * outputs to a single csv files
#     --> data/csv/repositories_details.csv
#
#------------------------------------------------------------------#
# Author: Philipp Staender (philipp.staender@rwth-aachen.de)       #
#------------------------------------------------------------------#

# Loading and preparing R
# reset environment
ls()
rm(list=ls(all=TRUE))
getwd()
setwd("/Users/philipp/masterthesis/")

# This includes some helper methods (e.g. latex export, pdf export …)
source('r/include.R')
source('r/include_filtered_repositories.R')   # repositories will be available as global `repositories`
source('r/include_filtered_organizations.R')  # org will be available as global `organizations`
source('r/include_firm_employed_developers_on_github.R')
Sys.setlocale("LC_TIME", "C")

# ratios <- read.csv('data/csv/schemas/contributions_ratio.csv')
# additionalCommitData <- read.csv('data/csv/schemas/code_commitment_additional_data.csv', stringsAsFactors = F)
# 
# dateTimeOfCommit <- read.csv('data/csv/schemas/datetime_of_commits.csv', stringsAsFactors = F)

allCommits <- read.csv('data/csv/calculated/optional/all_commits.csv', header = T, stringsAsFactors = F)
allCommits$timeZoneHour <- as.integer(gsub("^.*([-\\+][0-9]{1,2})([0-9]{2})$","\\1",allCommits$date_string))
additionalCommitData <- read.csv('data/csv/calculated/optional/additional_commit_data.csv', header = T, stringsAsFactors = F)
#Sat Dec 03 2011 02:38:15 GMT+0100 (CET)
library(ggplot2)
# require(scales)
theme_set(theme_gray(base_size = 18))

allCommits$`Firm Developer` <- 'no'
allCommits[allCommits$is_firm_employed == T, ]$`Firm Developer` <- 'yes'

ggplot(data=allCommits, aes(allCommits$hour_of_commit, fill=`Firm Developer`)) + 
#   geom_histogram(aes(y =..density..), 
#                  # breaks=seq(0,24, by=1), 
#                  binwidth=1,
#                  # col="black", 
#                  # fill="black", 
#                  alpha = .9) + 
  # geom_histogram(binwidth=1, alpha=.7, position="identity") +
  stat_density(alpha=.7, adjust=2) +
  # geom_density() + 
  # labs(title="Histogram for daytime worldwide (of code contribution)") +
  labs(x="Hour of Daytime", y="")


ggplot(data=allCommits, aes(allCommits$hour_of_commit_local, fill=`Firm Developer`)) + 
  stat_density(alpha=.7, adjust=2) +
  # labs(title="Histogram for daytime (of code contribution)") +
  labs(x="Hour of Daytime", y="")

h <- hist(allCommits[allCommits$is_firm_employed == T, ]$hour_of_commit, breaks=24, col="red", xlab="Hour of daytime (code contribution)", main="Histogram with Normal Curve") 
h <- hist(allCommits[allCommits$is_firm_employed == T, ]$hour_of_commit_local, breaks=24, col="red", xlab="Hour of daytime (code contribution)", main="Histogram with Normal Curve") 

# on which month

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
  # labs(title="Histogram for Month (of code contribution)") +
  labs(x="Month", y="") +
  scale_x_discrete(limits=1:12)

ggplot(data=allCommits, aes(allCommits$timeZoneHour, fill=`Firm Developer`)) + 
  stat_density(alpha=.7, adjust=4) +
  # labs(title="Histogram for Month (of code contribution)") +
  labs(x="Time Zone", y="")
  # scale_x_discrete(limits=1:12)

# summary(allCommits)

# d <- density(allCommits$hour_of_commit)

