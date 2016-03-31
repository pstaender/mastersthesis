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

require(xts)
require(PerformanceAnalytics)

outputAsPDF = pdfFilename = paste0("graphics/watch_forks_events") #.pdf will be attached later

lineWidth = 2


# This includes some helper methods (e.g. latex export, pdf export …)
source('r/include.R')
source('r/include_filtered_repositories.R')   # repositories will be available as global `repositories`
source('r/include_filtered_organizations.R')  # org will be available as global `organizations`
source('r/include_firm_employed_developers_on_github.R')
# source('r/include_dialog_input.R')

## 2. Repositories by (commercial) firms
customColors = adjustcolor(brewer.pal(4, "Paired"), alpha.f = 0.9) # "Blues"
customLines = c(1, 1)
# repositories <- repositories[order(repositories$full_name), ]
allFirmsRepos <- repositories[repositories$is_by_commercial_organization == 'true',]
allFirmsRepos <- subset(allFirmsRepos, allFirmsRepos$owner.login == 'spotify')
allFirmsRepos$folder <- paste0(allFirmsRepos$organization_name, '_', allFirmsRepos$repository_name)

sectionSwitch = 'events_and_commits'

if (!(sectionSwitch %in% c('watch_and_fork_events', 'commits', 'events_and_commits'))) {
  stop(paste0("your selected section switch '", sectionSwitch, "' is not available."))
} else if (sectionSwitch == 'watch_and_fork_events') {
  for (isTopProject in c(TRUE,FALSE)) {
    source('r/08a_include_time_series_of_fork_and_watch_events.R')
  }
} else if (sectionSwitch == 'commits') {
  writeOutputAsPDF = T
  # cut off below year …
  minimumYear = 2000
  lineWidth = 3
  # int, ext
  # customColors = c('#63c000', '#f7c3c3')
  customColors = c('#222222', '#FFC748')
  # customColors = c('#111111', '#888888')
  customLines = c(1, 1)
  applyFrequence = 'weekly'
  
  for (isTopProject in c(TRUE,FALSE)) {
    source('r/08b_include_time_series_of_code_contribution.R')
  }
} else if (sectionSwitch == 'events_and_commits') {
  for (isTopProject in c(TRUE,FALSE)) {
    source('r/08c_include_time_series_of_fork_and_watch_events.R')
  }
}
