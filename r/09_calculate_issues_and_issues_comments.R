#------------------------------------------------------------------#
#
# Calculate issues and issues comments by length of the content
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

outputAsPDF = paste0("graphics/introduction.pdf")
issueRatioToFile = "data/csv/calculated/issue_ratio.csv"
issueCommentRatioToFile = "data/csv/calculated/issue_comment_ratio.csv"

lineWidth = 2
if (outputAsPDF != F) {
  pdf(outputAsPDF, paper='A4r')#width=10, height=10)
  par(mfrow=c(2,2))
}

commercialOrganizationsAttributes = c('yes')

# This includes some helper methods (e.g. latex export, pdf export …)
source('r/include.R')
source('r/include_filtered_repositories.R')   # repositories will be available as global `repositories`
source('r/include_filtered_organizations.R')  # org will be available as global `organizations`
source('r/include_firm_employed_developers_on_github.R')
# source('r/include_dialog_input.R')

## 2. Repositories by (commercial) firms
customColors = adjustcolor(brewer.pal(4, "Paired"), alpha.f = 0.9) # "Blues"
customLines = c(1, 1)
firmsRepos <- repositories[repositories$is_by_commercial_organization == 'true',]
firmsRepos$folder <- paste0(firmsRepos$organization_name, '_', firmsRepos$repository_name)

checkUserIsFirmEmployed <- function(userID, organizationLogin = NULL) {
  #as.logical(
  # employedInFirms <- manualClassification[manualClassification$email == tolower(email), 1]
  if (is.character(organizationLogin)) {
    return(isUserFromFirm(as.numeric(userID), organizationLogin))
  } else {
    return(isUserFromFirm(as.numeric(userID)))
  }
}

countDone = 0

csvFieldNames <- c(
  "organization.login",
  "repository",
  "issues_issuescomments_count",
  "issues_count_by_firm_employed_developer",
  "issues_count_by_crossfirm_employed_developer",
  "all_content_size",
  "content_size_by_firm_employed_developer",
  "content_size_by_crossfirm_employed_developer",
  "issues_share_by_firm_employed_developer",
  "issues_share_by_crossfirm_employed_developer",
  "content_share_by_firm_employed_developer",
  "content_share_by_crossfirm_employed_developer",
  "issue_class", #issue,comments
  "repository.id",
  "is_top_project"
)

if (is.character(issueRatioToFile)) { write.table(as.list(csvFieldNames), file = issueRatioToFile, append = F, sep=",", row.names=FALSE, col.names=FALSE) }
if (is.character(issueCommentRatioToFile)) { write.table(as.list(csvFieldNames), file = issueCommentRatioToFile, append = F, sep=",", row.names=FALSE, col.names=FALSE) }

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
  
  ## 2. Caclulate ratio on issues ###
  
  fileIssues <- paste0('data/csv/repositories/issues/issues_', organizationLogin, '.csv')
  issues <- read.csv(fileIssues, header = T, stringsAsFactors = F)
  issues <- subset(issues, issues$url == paste0(organizationLogin, '/', repositoryName))

  if (nrow(issues) > 0) {
    
    issues$body <- as.numeric(issues$body)
    if (nrow(issues[is.na(issues$body),]) > 0) {
      issues[is.na(issues$body),]$body <- 0
    }
    issues <- cbind(issues, is_by_firm_employed_developer = mapply(checkUserIsFirmEmployed, issues$user.id, organizationLogin))
    issues <- cbind(issues, is_by_crossfirm_employed_developer = mapply(checkUserIsFirmEmployed, issues$user.id))
    # issues$by_firm_employed_developer <- isUserFromFirm(issues$user.id)
    data <- c(
      organizationLogin,
      repositoryName,
      nrow(issues),
      nrow(issues[issues$is_by_crossfirm_employed_developer == T, ]),
      nrow(issues[issues$is_by_firm_employed_developer == T, ]),
      sum(issues$body),
      sum(issues[issues$is_by_firm_employed_developer == T, ]$body),
      sum(issues[issues$is_by_crossfirm_employed_developer == T, ]$body),
      ( ( nrow(issues[issues$is_by_firm_employed_developer == T, ]) ) / ( nrow(issues) ) ),
      ( ( nrow(issues[issues$is_by_crossfirm_employed_developer == T, ]) ) / ( nrow(issues) ) ),
      ( ( sum(issues[issues$is_by_firm_employed_developer == T, ]$body) ) / ( (sum(issues$body)) ) ),
      ( ( sum(issues[issues$is_by_crossfirm_employed_developer == T, ]$body) ) / ( (sum(issues$body)) ) ),
      "issue",
      repo$id,
      repo$is_top_repository
    )
    
    if (is.character(issueRatioToFile)) {
      write.table(as.list(data), file = issueRatioToFile, append = T, sep=",", row.names=FALSE, col.names=FALSE)
    }
  }
  
  ## 3. Caclulate ratio on issue comment ###
  
  fileIssuesComments <- paste0('data/csv/repositories/issues_comments/issues_comments_', organizationLogin, '.csv')
  issuesComments <- read.csv(fileIssuesComments, header = T, stringsAsFactors = F)
  issuesComments <- subset(issuesComments, issuesComments$url == paste0(organizationLogin, '/', repositoryName))
  
  if (nrow(issuesComments) > 0) {
    
    issuesComments$body <- as.numeric(issuesComments$body)
    if (nrow(issuesComments[is.na(issuesComments$body),]) > 0) {
      issuesComments[is.na(issuesComments$body),]$body <- 0
    }
    issuesComments <- cbind(issuesComments, is_by_firm_employed_developer = mapply(checkUserIsFirmEmployed, issuesComments$user.id, organizationLogin))
    issuesComments <- cbind(issuesComments, is_by_crossfirm_employed_developer = mapply(checkUserIsFirmEmployed, issuesComments$user.id))
    data <- c(
      organizationLogin,
      repositoryName,
      nrow(issuesComments),
      nrow(issuesComments[issuesComments$is_by_crossfirm_employed_developer == T, ]),
      nrow(issuesComments[issuesComments$is_by_firm_employed_developer == T, ]),
      sum(issuesComments$body),
      sum(issuesComments[issuesComments$is_by_firm_employed_developer == T, ]$body),
      sum(issuesComments[issuesComments$is_by_crossfirm_employed_developer == T, ]$body),
      ( ( nrow(issuesComments[issuesComments$is_by_firm_employed_developer == T, ]) ) / ( nrow(issuesComments) ) ),
      ( ( nrow(issuesComments[issuesComments$is_by_crossfirm_employed_developer == T, ]) ) / ( nrow(issuesComments) ) ),
      ( ( sum(issuesComments[issuesComments$is_by_firm_employed_developer == T, ]$body) ) / ( (sum(issuesComments$body)) ) ),
      ( ( sum(issuesComments[issuesComments$is_by_crossfirm_employed_developer == T, ]$body) ) / ( (sum(issuesComments$body)) ) ),
      "issue_comments",
      repo$id,
      repo$is_top_repository
    )
    
    if (is.character(issueCommentRatioToFile)) {
      write.table(as.list(data), file = issueCommentRatioToFile, append = T, sep=",", row.names=FALSE, col.names=FALSE)
    }
  }
  
}

if (outputAsPDF != F) {
  dev.off()
}