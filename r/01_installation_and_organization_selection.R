#------------------------------------------------------------------#
#
# Get most popular repositories from GitHub
#
# Get all top projects for each language (optional)
#
#------------------------------------------------------------------#
# Author: Philipp Staender (philipp.staender@rwth-aachen.de)       #
#------------------------------------------------------------------#

#------------------------------------------------------------------#

## Part 1: Prepare / clear environment and load modules ####
ls()
rm(list=ls(all=TRUE))
getwd()
setwd("~/mastersthesis/")
# include basic user defined methods
source('r/include.R')

# 1.1 load the generated CSV file with all popular repositories for all 10 programming languges:

topRepositories <- read.csv(paste0("data/csv/top_repositories.csv"),  header=TRUE)
# sorting out users, only keep organizations
topRepositories <- subset(topRepositories, topRepositories$owner.type == 'Organization')
# convert date
topRepositories$created_at = as.Date(as.character(topRepositories$created_at), format = "%Y-%m-%dT%H:%M:%SZ")
topRepositories$updated_at = as.Date(as.character(topRepositories$updated_at), format = "%Y-%m-%dT%H:%M:%SZ")

stargazer(topRepositories, type="text")

library('plyr')

# 1.2 Select relevant Organizations

organizationsRepositoriesCount <- ddply(topRepositories,~owner.login,summarise,number_of_distinct_repos=length(unique(id)))
# order by number of distinct orders (descending)
organizationsRepositoriesCount <- organizationsRepositoriesCount[order(-organizationsRepositoriesCount$number_of_distinct_repos),]
print(paste0(nrow(organizationsRepositoriesCount), " repositories of organizations count"))

# the lower bound is at least 4 repositories
organizationsRepositoriesCount <- subset(organizationsRepositoriesCount, organizationsRepositoriesCount$number_of_distinct_repos > 3)
print(paste0(nrow(organizationsRepositoriesCount), " relevant organizations with at least 4 popular repositories"))

# merge counted repositories to company
relevantOrganization <- merge(organizationsRepositoriesCount, topRepositories, by = c("owner.login"))
print(paste0(nrow(organizationsRepositoriesCount), " repositories of relevant organizations"))
organizationsRepositoriesCount$isCommercial <- '' # needs to be done manually in the generated csv

# export all organizations to csv file to apply a qualitative classification of commercial (yes, no, partly)
csvFileName = 'csv/commercial_classification/commercial_classification_of_organizations_which_needs_to_be_classified.csv'
writeToFile(organizationsRepositoriesCount, csvFileName)

# 1.3 Classify commercial firms (manually)

stop(paste0("Action Needed: All organizations need now to be classified in [yes,no,partly], see file ->'", csvFileName, "'"))

# 1.4 Export as CSV file

# read / import manually classified csv file
commercialOrganizations <- read.csv('data/csv/commercial_classification/commercial_classification_of_organizations.csv', header = T)
commercialOrganizations <- subset(commercialOrganizations, commercialOrganizations$is_commercial %in% c('yes', 'partly'))

# renumbering rows
row.names(commercialOrganizations) <- 1:nrow(commercialOrganizations)
# summary
print(paste0(nrow(subset(commercialOrganizations, commercialOrganizations$is_commercial == "yes")), " commercial organizations"))
print(paste0(nrow(subset(commercialOrganizations, commercialOrganizations$is_commercial == "partly")), " partly commercial organizations"))

writeToFile(commercialOrganizations, 'csv/selected_commercial_organizations.csv', '')
