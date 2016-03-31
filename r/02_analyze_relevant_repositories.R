# Loading and preparing R

# reset environment
ls()
rm(list=ls(all=TRUE))
getwd()
setwd("/Users/philipp/masterthesis/")

# only initially

# This includes some helper methods (e.g. latex export, pdf export …)
source('r/include.R')

# load the generated CSV file with all popular repositories for all 10 programming languges:

repositories <- read.csv(paste0("data/csv/repositories_details.csv"),  header=T)

organizations <- read.csv(paste0("data/csv/organizations.csv"),  header=T)

commercialOrganizations <- read.csv(paste0("data/csv/commercial_classification/commercial_classification_of_organizations.csv"),  header=T)

# merge
organizations <- merge(organizations, commercialOrganizations, by = c("login"))


organizations[organizations$email == 'null','email'] <- ''
organizations[organizations$blog == 'null','blog'] <- ''
# email pattern
organizations$email_pattern_domain <- gsub("^(http[s]*\\:\\/\\/|http[s]*\\:\\/\\/www\\.|www\\.)(.+)$", "\\2", organizations$blog)
organizations$email_pattern_domain <- gsub("^(.+?)(\\/).*$", "\\1", organizations$email_pattern_domain)
organizations$email_pattern_domain <- gsub("^(.+?)(\\..+?)(\\..+?)$", "\\2\\3", organizations$email_pattern_domain)
organizations$email_pattern_domain <- gsub("^\\.+", "", organizations$email_pattern_domain)

# write to csv file(s) ?
writeToFile = T

organizations$email_pattern_email <- gsub("^[^@]+@(.+?)$", "\\1", organizations$email)
#, ignore.case = FALSE

# convert true | false to R boolean
repositories$is_top_repository <- as.logical(repositories$is_top_repository)
# convert date
repositories$created_at = as.Date(as.character(repositories$created_at), format = "%Y-%m-%dT%H:%M:%SZ")
repositories$updated_at = as.Date(as.character(repositories$updated_at), format = "%Y-%m-%dT%H:%M:%SZ")
# calculate age in days
repositories$age = round((repositories$updated_at - repositories$created_at) / 365, digits = 2)

# summary(repositories)

# sorting out repos
# only with > 1 commits
# and older > 1 months
repositories <- subset(repositories, repositories$commits_count > 1)
repositories <- subset(repositories, repositories$age >= 0.1)
# set the filename
repositories$log_filename <- paste0('logs_', repositories$organization_name, '_', repositories$repository_name, '.csv')

# select specific organizations
organizations <- subset(organizations, organizations$is_commercial == 'yes')
# organizations <- subset(organizations, organizations$login %in% c('airbnb'))

for (organization in organizations$login) {
  repos <- subset(repositories, repositories$organization_name == toString(organization))
  commits <- read.csv('data/csv/schema/commits_schema.csv', header=TRUE)
  for (logfilename in repos$log_filename) {
    repoCommits <- read.csv(paste0('data/csv/repositories/logs/', logfilename),  header=TRUE)
    repoCommits$organization <- toString(organization)
    commits <- rbind(commits, repoCommits)
  }
  percentageOfContribution <- sort(table(commits$author.email), decreasing=T)
  percentageOfContribution <- as.data.frame(percentageOfContribution)
  filename <- paste0("data/csv/calculated/contributions/top_contributors_", toString(organization), ".csv")
  props <- as.data.frame(prop.table(percentageOfContribution))
  props <- subset(props, props$percentageOfContribution >= 0.01)

  if (writeToFile == T) {
    print(filename)
    write('"author.email","percentage_of_contribution","is_employed"', filename, sep = "")
    props$is_employed <- ''
    write.table(props, filename, append = T, col.names = F,  sep = ",")
  } else {
    print(props)
  }
}
