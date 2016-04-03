#------------------------------------------------------------------#
#
# H2: Linear regression of Participation on Issues and Issues Comments 
#
#------------------------------------------------------------------#
# Author: Philipp Staender (philipp.staender@rwth-aachen.de)       #
#------------------------------------------------------------------#

## 1. Prepare / clear environment and load modules ####
ls()
rm(list=ls(all=TRUE))
getwd()
setwd("~/mastersthesis/")
source('r/include.R')
source('r/include_filtered_organizations.R')  # org will be available as global `organizations`
source('r/include_subsetvalues.R')
source('r/include_filtered_repositories.R')

repositories$repository.id <- repositories$id

resultFolderName <- 'statistics/issue_participation_results/'

outputDataToFile = F

# load the calculated CSV file with all popular repositories for all 10 programming languges:
issues <- read.csv(paste0("data/csv/calculated/issue_ratio.csv"), header = T, stringsAsFactors = F)
issuesComments <- read.csv(paste0("data/csv/calculated/issue_comment_ratio.csv"), header = T, stringsAsFactors = F)
# codeContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T, stringsAsFactors = F)
# codeContributions$repository.id <- codeContributions$github_id
issuesComments$all_issue_comments_count <- issuesComments$issues_issuescomments_count
issuesComments$issues_comment_share_by_firm_employed_developer <- issuesComments$issues_share_by_firm_employed_developer
issuesComments$issues_comment_share_by_crossfirm_employed_developer <- issuesComments$issues_share_by_crossfirm_employed_developer
issuesComments$issues_comment_share_by_external_employed_developer <- 1 - issuesComments$issues_comment_share_by_crossfirm_employed_developer
issuesComments$firm_employed_developer_share_on_content <-
issuesComments$crossfirm_developer_share_on_content <- (1 / issuesComments$all_content_size) * issuesComments$content_size_by_crossfirm_employed_developer
issuesComments <- merge(issuesComments, repositories, by = c('repository.id'))
# issuesComments <- merge(issuesComments, codeContributions, by = c('repository.id'))
issuesComments <- subset(issuesComments, issuesComments$language %in% OBSERVED_LANGUAGES)
issuesComments$ext_developer_share_on_content <- 1 - issuesComments$crossfirm_developer_share_on_content
issuesComments$top_repo <- as.numeric(issuesComments$is_top_repository)
issuesComments$firm_ <- issuesComments$organization.login
issuesComments$lang_ <- issuesComments$language
issuesComments <- na.omit(issuesComments)


# merge with detailed repro data
issues <- merge(issues, repositories, by = c('repository.id'))
issues <- subset(issues, issues$language %in% OBSERVED_LANGUAGES)
issues$all_issues_count <- issues$open_issues_count + issues$closed_issues_count
issues$crossfirm_developer_share_on_content <- (1 / issues$all_content_size) * issues$content_size_by_crossfirm_employed_developer
# Use this to check for strigtly firm employed developer (no sign. relation found)
issues$crossfirm_developer_share_on_content <- (1 / issues$all_content_size) * issues$content_size_by_firm_employed_developer
issues$ext_developer_share_on_content <- 1 - issues$crossfirm_developer_share_on_content
issues$top_repo <- as.numeric(issues$is_top_repository)
issues$firm_ <- issues$organization.login
issues$lang_ <- issues$language
issues$issues_count_by_external_developer <- issues$issues_count - issues$issues_count_by_firm_employed_developer

# remove projects with NA
issues <- na.omit(issues)

## Generalized Linear Model ####
# Does the size of an issue and the issue authorship of firm employed or not firm employed developer
# influce the popularity on long term?

linear.1 <- glm(formula = stargazers_count ~ age + issues_count_by_firm_employed_developer + issues_count_by_external_developer + all_content_size, data = issues)
linear.2 <- glm(formula = forks_count ~ age + issues_count_by_firm_employed_developer + issues_count_by_external_developer + all_content_size, data = issues)
linear.3 <- glm(formula = subscribers_count ~ age + issues_count_by_firm_employed_developer + issues_count_by_external_developer + all_content_size, data = issues)
linear.4 <- glm(formula = stargazers_count ~ age + issues_share_by_firm_employed_developer + all_content_size, data = issues)
linear.5 <- glm(formula = forks_count ~ age + issues_share_by_firm_employed_developer + all_content_size, data = issues)
linear.6 <- glm(formula = subscribers_count ~ age + issues_share_by_firm_employed_developer + all_content_size, data = issues)

stargazer(linear.1, linear.2, linear.3, linear.4, linear.5, linear.6, type="text")

linear.1 <- glm(formula = stargazers_count ~ age + all_content_size, data = issues)
linear.2 <- glm(formula = stargazers_count ~ age + crossfirm_developer_share_on_content, data = issues)
linear.3 <- glm(formula = subscribers_count ~ age + all_content_size, data = issues)
linear.4 <- glm(formula = subscribers_count ~ age + crossfirm_developer_share_on_content, data = issues)
linear.5 <- glm(formula = forks_count ~ age + all_content_size, data = issues)
linear.6 <- glm(formula = forks_count ~ age + crossfirm_developer_share_on_content, data = issues)
linear.7 <- glm(formula = top_repo ~ age + all_content_size, family=binomial(link='logit'), data = issues)
linear.8 <- glm(formula = top_repo ~ age + crossfirm_developer_share_on_content, family=binomial(link='logit'), data = issues)

stargazer(linear.1, linear.2, linear.3, linear.4, linear.5, linear.6, linear.7, linear.8, type="text")

linear.1 <- glm(formula = top_repo ~ age + all_content_size, family=binomial(link='logit'), data = issues)
linear.2 <- glm(formula = top_repo ~ age + crossfirm_developer_share_on_content, family=binomial(link='logit'), data = issues)
linear.3 <- glm(formula = top_repo ~ age + all_content_size, family=binomial(link='logit'), data = issues)
linear.4 <- glm(formula = top_repo ~ age + crossfirm_developer_share_on_content, family=binomial(link='logit'), data = issues)

stargazer(linear.1, linear.2, linear.3, linear.4, type="text")

## Mixed-effect modeling

# group by organization

mixedeffect.1 <- lmer(formula = stargazers_count  ~ age + crossfirm_developer_share_on_content + (1 | organization_name), data = issues)
mixedeffect.2 <- lmer(formula = subscribers_count ~ age + crossfirm_developer_share_on_content + (1 | organization_name), data = issues)
mixedeffect.3 <- lmer(formula = forks_count       ~ age + crossfirm_developer_share_on_content + (1 | organization_name), data = issues)
mixedeffect.4 <- lmer(formula = top_repo          ~ age + crossfirm_developer_share_on_content + (1 | organization_name), family=binomial(link='logit'), data = issues)

stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, type="text")

# group by organization + language

mixedeffect.1 <- lmer(formula = stargazers_count  ~ age + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issues)
mixedeffect.2 <- lmer(formula = subscribers_count ~ age + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issues)
mixedeffect.3 <- lmer(formula = forks_count       ~ age + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issues)
mixedeffect.4 <- lmer(formula = top_repo          ~ age + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), family=binomial(link='logit'), data = issues)

stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, type="text")




## ISSUE COMMENT
## nicht aussagekräftig
## --> see 05c_ instead

mixedeffect.1 <- lmer(formula = stargazers_count  ~ age + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.2 <- lmer(formula = subscribers_count ~ age + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.3 <- lmer(formula = forks_count       ~ age + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.4 <- lmer(formula = all_content_size  ~ age + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.5 <- lmer(formula = all_issue_comments_count ~ age + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.6 <- lmer(formula = top_repo          ~ age + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), family=binomial(link='logit'), data = issuesComments)

stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, mixedeffect.5, mixedeffect.6, type="text")

mixedeffect.1 <- lmer(formula = all_issue_comments_count ~ contributors_count + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.2 <- lmer(formula = subscribers_count        ~ contributors_count + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.3 <- lmer(formula = forks_count              ~ contributors_count + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.4 <- lmer(formula = all_content_size         ~ contributors_count + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.5 <- lmer(formula = all_issue_comments_count ~ contributors_count + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.6 <- lmer(formula = top_repo                 ~ contributors_count + crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), family=binomial(link='logit'), data = issuesComments)

stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, mixedeffect.5, mixedeffect.6, type="text")


# mixedeffect.1 <- lmer(formula = contributors_count ~ crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
# mixedeffect.2 <- lmer(formula = all_issue_comments_count ~ crossfirm_developer_share_on_content + (1 | organization_name) + (1 | language), data = issuesComments)
# stargazer(mixedeffect.1, mixedeffect.2, type="text")



mixedeffect.1 <- lmer(formula = crossfirm_developer_share_on_content         ~ contributors_count + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.2 <- lmer(formula = ext_developer_share_on_content               ~ contributors_count + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.3 <- lmer(formula = content_share_by_firm_employed_developer     ~ contributors_count + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.4 <- lmer(formula = issues_count_by_firm_employed_developer ~ contributors_count + (1 | organization_name) + (1 | language), data = issuesComments)
mixedeffect.5 <- lmer(formula = issues_count_by_crossfirm_employed_developer ~ contributors_count + (1 | organization_name) + (1 | language), data = issuesComments)

stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, mixedeffect.5, type="text")


# 
# 
# linear.1 <- glm(formula = stargazers_count  ~ age + crossfirm_developer_share_on_content + lang_ + firm_ , data = issuesComments)
# linear.2 <- glm(formula = stargazers_count  ~ age + crossfirm_developer_share_on_content + lang_ + firm_, data = issuesComments)
# linear.3 <- glm(formula = subscribers_count ~ age + crossfirm_developer_share_on_content + lang_ + firm_, data = issuesComments)
# linear.4 <- glm(formula = subscribers_count ~ age + crossfirm_developer_share_on_content + lang_ + firm_, data = issuesComments)
# linear.5 <- glm(formula = forks_count       ~ age + crossfirm_developer_share_on_content + lang_ + firm_, data = issuesComments)
# linear.6 <- glm(formula = forks_count       ~ age + crossfirm_developer_share_on_content + lang_ + firm_, data = issuesComments)
# linear.7 <- glm(formula = top_repo          ~ age + crossfirm_developer_share_on_content + lang_ + firm_, family=binomial(link='logit'), data = issuesComments)
# linear.8 <- glm(formula = top_repo          ~ age + crossfirm_developer_share_on_content + lang_ + firm_, family=binomial(link='logit'), data = issuesComments)
# 
# stargazer(linear.1, linear.2, linear.3, linear.4, linear.5, linear.6, linear.7, linear.8, type="text")
