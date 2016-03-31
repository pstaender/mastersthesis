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

library(lubridate) # to get hours of datetime

calculateIntExtRatio = T

# write to csv file(s) ?
# set to FALSE in case of you don't want to (over)write an existing csv file
outputCSVFileTopExternalContributors = F#'data/csv/calculated/top_external_contributors.csv'
#outputCSVFileRatio = 'data/csv/calculated/contributions_ratio_t.csv'

# counter (needed to get organization row)

ratios <- read.csv('data/csv/schemas/contributions_ratio.csv')
additionalCommitData <- read.csv('data/csv/schemas/code_commitment_additional_data.csv', stringsAsFactors = F)

dateTimeOfCommit <- read.csv('data/csv/schemas/datetime_of_commits.csv', stringsAsFactors = F)

allCommits <- read.csv('data/csv/schemas/commits_additional_data_schema.csv', stringsAsFactors = F)

library(ggplot2)
# require(scales)
theme_set(theme_gray(base_size = 18))

# organizations$login
# c('alibaba')

for (organizationLogin in organizations$login) {
  
  firmEmployedDevelopers <- c()
  externalDevelopers <- c()
  
  print(paste0('-> processing: ', toString(organizationLogin)))
  # select repos from selected organization
  repos <- subset(repositories, repositories$organization_name == toString(organizationLogin))
  organization <- organizations[organizations$login == organizationLogin,]
  organizationsEmailPattern <- toString(organization$email_domain)
  j=0 # counter for repos
  

  
  for (logfilename in repos$log_filename) {
  #logfilename <- repos$log_filename[1]
    j=j+1
    commits <- read.csv(paste0('data/csv/repositories/logs/', logfilename),  header=TRUE, stringsAsFactors=FALSE)
    commits$valid_email <- as.logical(regexpr(regexValidEmail, commits$author.email, ignore.case = T) == 1)
    # remove all commits with invalid email addresses from observation
    for (excludePattern in excludeEmailPatterns) {
      commits <- subset(commits, commits$valid_email == T)
      commits$valid_email <- as.logical(regexpr(excludePattern, commits$author.email, ignore.case = T) == -1)
    }
    commits <- subset(commits, commits$valid_email == T)
    # mark all firm employed developers defined by regex pattern in `commercial_classification_of_organizations.csv` for each organization
    commits$is_firm_employed <- as.logical(regexpr(organizationsEmailPattern, commits$author.email, ignore.case = T) >= 0)
    # classify manually with whitelist (int_ext_developer_classification.csv)
#     commits <- cbind(commits, is_firm_employed_manually = mapply(function(email) {
#       #as.logical(
#       employedInFirms <- manualClassification[manualClassification$email == tolower(email), 1]
#       tolower(toString(organization$login)) %in% tolower(strsplit(toString(employedInFirms), "\\|")[[1]])
#     }, commits$author.email))
    commits <- cbind(commits, is_firm_employed_manually = mapply(isUserFromFirm, commits$author.email, organizationLogin, T))
    commits[commits$is_firm_employed_manually == T, ]$is_firm_employed <- commits[commits$is_firm_employed_manually == T, ]$is_firm_employed_manually

    
    commits$hour_of_commit <- as.numeric(sub("^[a-zA-Z]+\\s+[a-zA-Z]+\\s+[0-9]+\\s+[0-9]+\\s([0-9]{2}):.*$", '\\1', commits$date, ignore.case = T))
    commits$hour_of_commit_local <- as.numeric(sub("^[a-zA-Z]+\\s+[a-zA-Z]+\\s+[0-9]+\\s+([0-9]{2}):.*$", '\\1', commits$date_string, ignore.case = T))
    
    

    repo <- repos[j,]
    repoApiData <- allOrganizationsRepos[allOrganizationsRepos$full_name == paste0(toString(organization$login), '/', toString(repo$repository_name)), ]

    allCommitsCount = nrow(commits)
    firmEmployedCount = sum(commits$is_firm_employed == T)

    commits$organization.login = as.character(repoApiData$owner.login)
    commits$repository.name = as.character(repoApiData$name)
    commits$repository.id = as.numeric(repoApiData$id)
    
    
    
    allCommits <- rbind(allCommits, commits)
    
    # additional commit data
    
    additionalCommitData[nrow(additionalCommitData)+1,] <- c(
      length(unique(commits[commits$is_firm_employed == T, ]$author.email)),
      length(unique(commits[commits$is_firm_employed == F, ]$author.email)),
      as.numeric(allCommitsCount),                 # all_commits_count
      as.numeric(firmEmployedCount),               # internal_commits_count
      repoApiData$id,
      repoApiData$owner.login,
      repoApiData$name,
      ''
    )
    firmEmployedDevelopers <- unique(append(firmEmployedDevelopers, commits[commits$is_firm_employed == T, ]$author.email))
    externalDevelopers <- unique(append(externalDevelopers, commits[commits$is_firm_employed == F, ]$author.email))
    
    
  }
  additionalCommitData[additionalCommitData$owner.login == organizationLogin, ]$numbers_of_commiters_int <- length(firmEmployedDevelopers)
  additionalCommitData[additionalCommitData$owner.login == organizationLogin, ]$numbers_of_commiters_ext <- length(externalDevelopers)
  additionalCommitData[additionalCommitData$owner.login == organizationLogin, ]$commiters_email_int <- implode(firmEmployedDevelopers)

}


ggplot(data=allCommits, aes(allCommits$hour_of_commit)) + 
  geom_histogram(aes(y =..density..), 
                 breaks=seq(0,24, by=1), 
                 # col="black", 
                 # fill="black", 
                 alpha = .9) + 
  geom_density(col=1, aes(group=hour_of_commit)) + 
  labs(title="Histogram for daytime of commit") +
  labs(x="Hour of Daytime (code contribution)", y="Count")

h <- hist(allCommits[allCommits$is_firm_employed == T, ]$hour_of_commit, breaks=24, col="red", xlab="Hour of daytime (code contribution)", main="Histogram with Normal Curve") 
h <- hist(allCommits[allCommits$is_firm_employed == T, ]$hour_of_commit_local, breaks=24, col="red", xlab="Hour of daytime (code contribution)", main="Histogram with Normal Curve") 

# d <- density(allCommits$hour_of_commit)


#write.csv(allCommits, "~/all_commits.csv", sep = ",", row.names = F)
#write.csv(additionalCommitData, "~/additional_commit_data.csv", sep = ",", row.names = F)
