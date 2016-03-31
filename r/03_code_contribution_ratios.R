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

calculateIntExtRatio = T

# write to csv file(s) ?
# set to FALSE in case of you don't want to (over)write an existing csv file
outputCSVFileTopExternalContributors = 'data/csv/calculated/top_external_contributors.csv'
outputCSVFileRatio = 'data/csv/calculated/contributions_ratio.csv'

if ((exists('outputCSVFileTopExternalContributors', inherits = F) && (typeof(outputCSVFileTopExternalContributors) == 'character'))) {
  write('"author.email","percentage_of_contribution","organization"', outputCSVFileTopExternalContributors, sep = "")
}

# counter (needed to get organization row)

ratios <- read.csv('data/csv/schemas/contributions_ratio.csv')

# organizations$login
# c('alibaba')

for (organizationLogin in organizations$login) {
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

    if (calculateIntExtRatio == T) {
      repo <- repos[j,]
      repoApiData <- allOrganizationsRepos[allOrganizationsRepos$full_name == paste0(toString(organization$login), '/', toString(repo$repository_name)), ]

      allCommitsCount = nrow(commits)
      firmEmployedCount = sum(commits$is_firm_employed == T)
      ratios[nrow(ratios)+1,] = c(
        toString(repo$organization_name),            # organization_name
        toString(repo$repository_name),              # repository_name
        as.logical(repo$is_top_repository),          # is_top_project
        as.numeric(repo$age),                        # age
        toString(repoApiData$language),              # language
        as.logical(repoApiData$fork),                # fork
        as.numeric(repoApiData$size),                # size
        as.numeric(repoApiData$id),                  # github_id
        as.numeric(allCommitsCount),                 # all_commits_count
        as.numeric(firmEmployedCount),               # internal_commits_count
        as.numeric(repo$closed_issues_count),        # closed_issues_count
        as.numeric(repo$open_issues_count),          # open_issues_count
        as.numeric(repoApiData$stargazers_count),    # stargazers_count
        as.numeric(repo$contributors_count),         # contributors_count
        as.numeric(repo$subscribers_count),          # subscribers_count
        as.numeric(repoApiData$forks_count),         # forks_count
        toString(repo$license),                      # license
        0                                            # ratio of internal developers (will be calculated later)
      )
    }
    # stop()
  }
}

# calculate the ratio of internal developers
ratios$ratio <- as.numeric(( 1 / as.numeric(ratios$all_commits_count )) * as.numeric(ratios$internal_commits_count))

if ((calculateIntExtRatio == T) && (exists('outputCSVFileRatio', inherits = F) && (typeof(outputCSVFileRatio) == 'character'))) {
  write.csv(ratios, outputCSVFileRatio, row.names=FALSE)
}
