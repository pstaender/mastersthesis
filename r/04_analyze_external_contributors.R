#------------------------------------------------------------------#
#
# Analyze external contributors
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

# load the generated CSV file with all popular repositories for all 10 programming languges:
csvFileTopExternalContributors = 'data/csv/calculated/top_external_contributors.csv'
externalTopContributors <- read.csv(paste0(csvFileTopExternalContributors),  header=T)

organizations <- read.csv(paste0("data/csv/organizations.csv"),  header=T)

commercialOrganizations <- read.csv(paste0("data/csv/commercial_classification/commercial_classification_of_organizations.csv"),  header=T)

# merge
organizations <- merge(organizations, commercialOrganizations, by = c("login"))
# select specific organizations
organizations <- subset(organizations, organizations$is_commercial == 'yes')
# having an email domain
organizations <- organizations[!(organizations$email_domain==""), ]
# organizations <- subset(organizations, organizations$login %in% c('apple','airbnb'))

# write to csv file(s) ?
# writeToFile = T

# counter (needed to get organization row)
i=0

externalTopContributors$author.name <- ''

# get all contributor's name + email
for (organizationLogin in organizations$login) {
  print(paste0('-> processing: ', toString(organizationLogin)))
  i = i + 1
  organization <- organizations[i,]
  print(exists('contributors', inherits = F))
  csvData <- read.csv(paste0('data/csv/repositories/contributors/contributors_', toString(organizationLogin), '.csv'),  header=TRUE)
  if (!exists('contributors', inherits = F)) {
    contributors <- csvData
  } else {
    contributors <- rbind(contributors, csvData)
  }
}
# TODO: not working, match email with name
for (authorEmail in externalTopContributors$author.email) {
  print(authorEmail)
  print(contributors[contributors$email == toString(authorEmail), ])
}