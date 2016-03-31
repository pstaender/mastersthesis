#------------------------------------------------------------------#
#
# Linear regression in time segment
#
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

# This includes some helper methods (e.g. latex export, pdf export ...)
source('r/include.R')
source('r/include_filtered_organizations.R')  # org will be available as global `organizations`
source('r/include_subsetvalues.R')
source('r/include_linear_regression_plots.R')
source('r/include_firm_employed_developers_on_github.R')
library(dplyr)

observations <- read.csv('data/csv/schemas/time_obervations_in_section_code_and_events.csv', header = T, stringsAsFactors = F)

dateStringToAge <- function(date) {
  # convert strong dates from fork/watch events
  date = as.Date(as.character(date))
  if (is.na(date)) {
    date <- as.Date(as.character(date), format = "%Y/%m/%d %H:%M:%S %z")
  }
  if (is.na(date)) {
    date <- as.Date(as.character(date), format = "%Y-%m-%dT%H:%M:%S")
  }
  date <- as.numeric(difftime(Sys.Date(), date))
  return(date)
}

resultFolderName <- 'statistics/code_contribution/'

outputDataToFile = F

toFile <- function(content, file) {
  if (isTRUE(outputDataToFile)) {
    write(content, file)
  } else {
    print("skipping writing, set `outputDataToFile` to TRUE if you want to write file(s)")
  }
}

# load the generated CSV file with all popular repositories for all 10 programming languges:
allContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T)
allContributions$all_issues_count <- allContributions$closed_issues_count + allContributions$open_issues_count
allContributions$top_repo <- as.integer(allContributions$is_top_project)
allContributions$external_commits_count <- allContributions$all_commits_count - allContributions$internal_commits_count

firms <- organizations

contributions <- allContributions

contributions <- subset(contributions, contributions$language %in% OBSERVED_LANGUAGES)

age.1 = 91 # days (3 months)
age.2 = age.1*2 # half year
age.3 = age.2*2 # one year
age.4 = age.3*2 # two years

# age.max = 1095 # three years

contributions <- subset(contributions, contributions$age >= age.4)

# repoID = 455600 # facebook hhvm
#contributions$github_id
i=0
for (repoID in contributions$github_id) {
  i = i+1
  # if (i < 1166) {
  #   next
  # }
  repo <- contributions[contributions$github_id == repoID, ]
  
  print(paste0(repo$organization_name,'/',repo$repository_name,' ',i,'/',nrow(contributions)))
  
  organization <- organizations[organizations$login == repo$organization_name,]
  organizationsEmailPattern <- toString(organization$email_domain)
  
  folder = paste0(repo$organization_name, '_', repo$repository_name)
  fileFork <- paste0('data/csv/repositories/forkevent/forkevent_', folder, '.csv')
  fileEvent <- paste0('data/csv/repositories/watchevent/watchevent_', folder, '.csv')
  
  
  commitlogFilename <- paste0('data/csv/repositories/logs/logs_', folder, '.csv')
  if (!file.exists(commitlogFilename)) {
    next
  }
  commits <- read.csv(commitlogFilename, header = T, stringsAsFactors = F)
  
  commits <- subset(commits, nchar(commits$date) < 60)
  
  commits$age <- as.numeric(difftime(Sys.Date(), as.Date(as.character(commits$date), format ='%a %b %d %Y %H:%M:%S GMT%z')))
  
  # copyied from 03_code_contribution.R
  commits$valid_email <- as.logical(regexpr(regexValidEmail, commits$author.email, ignore.case = T) == 1)
  commits <- subset(commits, commits$valid_email == T)
  for (excludePattern in excludeEmailPatterns) {
    commits$valid_email <- as.logical(regexpr(excludePattern, commits$author.email, ignore.case = T) == -1)
  }
  # mark all firm employed developers defined by regex pattern in `commercial_classification_of_organizations.csv` for each organization
  commits$is_firm_employed <- as.logical(regexpr(organizationsEmailPattern, commits$author.email, ignore.case = T) >= 0)
  commits <- cbind(commits, is_firm_employed_manually = mapply(isUserFromFirm, commits$author.email, as.character(repo$organization_name), T))
  commits[commits$is_firm_employed_manually == T, ]$is_firm_employed <- commits[commits$is_firm_employed_manually == T, ]$is_firm_employed_manually
  
  events = NULL
  if (file.exists(fileFork)) {
    events <- read.csv(fileFork, header = T, stringsAsFactors = F)
  }
  if (file.exists(fileEvent)) {
    if (is.null(events)) {
      events <- read.csv(fileEvent, header = T, stringsAsFactors = F)
    } else {
      events <- rbind(events, read.csv(fileEvent, header = T, stringsAsFactors = F))
    }
  }
  
  code_contributions.1 <- commits[commits$age <= age.1, ]
  code_contributions.2 <- commits[commits$age > age.1 & commits$age <= age.2, ]
  code_contributions.3 <- commits[commits$age > age.2 & commits$age <= age.3, ]
  code_contributions.4 <- commits[commits$age > age.3 & commits$age <= age.4, ]
  code_contributions.5 <- commits[commits$age > age.4, ]
  
  code_contributions.int.1 = as.numeric(nrow(code_contributions.1[code_contributions.1$is_firm_employed == T,]))
  code_contributions.int.2 = as.numeric(nrow(code_contributions.1[code_contributions.2$is_firm_employed == T,]))
  code_contributions.int.3 = as.numeric(nrow(code_contributions.1[code_contributions.3$is_firm_employed == T,]))
  code_contributions.int.4 = as.numeric(nrow(code_contributions.1[code_contributions.4$is_firm_employed == T,]))
  code_contributions.int.5 = as.numeric(nrow(code_contributions.1[code_contributions.5$is_firm_employed == T,]))
  
  code_contributions.ext.1 = as.numeric(nrow(code_contributions.1[code_contributions.1$is_firm_employed == F,]))
  code_contributions.ext.2 = as.numeric(nrow(code_contributions.1[code_contributions.2$is_firm_employed == F,]))
  code_contributions.ext.3 = as.numeric(nrow(code_contributions.1[code_contributions.3$is_firm_employed == F,]))
  code_contributions.ext.4 = as.numeric(nrow(code_contributions.1[code_contributions.4$is_firm_employed == F,]))
  code_contributions.ext.5 = as.numeric(nrow(code_contributions.1[code_contributions.5$is_firm_employed == F,]))
  
  
  code_contributions.ratio.1 = (1 / (code_contributions.int.1 + code_contributions.ext.1)) * code_contributions.int.1
  code_contributions.ratio.2 = (1 / (code_contributions.int.2 + code_contributions.ext.2)) * code_contributions.int.2
  code_contributions.ratio.3 = (1 / (code_contributions.int.3 + code_contributions.ext.3)) * code_contributions.int.3
  code_contributions.ratio.4 = (1 / (code_contributions.int.4 + code_contributions.ext.4)) * code_contributions.int.4
  code_contributions.ratio.5 = (1 / (code_contributions.int.5 + code_contributions.ext.5)) * code_contributions.int.5
  
  if (is.na(code_contributions.ratio.1)) { code_contributions.ratio.1 = 0 }
  if (is.na(code_contributions.ratio.2)) { code_contributions.ratio.2 = 0 }
  if (is.na(code_contributions.ratio.3)) { code_contributions.ratio.3 = 0 }
  if (is.na(code_contributions.ratio.4)) { code_contributions.ratio.4 = 0 }
  if (is.na(code_contributions.ratio.5)) { code_contributions.ratio.5 = 0 }
  #[1] "spotify/linux 1166/1433"
  if ((!is.null(events)) && (nrow(events) > 0)) {
    events <- cbind(events, age = mapply(dateStringToAge, events$created_at))
    events$age <- as.numeric(events$age)
    
    subscribers.1 = as.numeric(nrow(events[events$type == 'WatchEvent' & events$age <= age.1, ]))
    subscribers.2 = as.numeric(nrow(events[events$type == 'WatchEvent' & events$age <= age.2, ]))
    subscribers.3 = as.numeric(nrow(events[events$type == 'WatchEvent' & events$age <= age.3, ]))
    subscribers.4 = as.numeric(nrow(events[events$type == 'WatchEvent' & events$age <= age.4, ]))
    subscribers.5 = as.numeric(nrow(events[events$type == 'WatchEvent' & events$age > age.4, ]))
    
    forks.1 = as.numeric(nrow(events[events$type == 'ForkEvent' & events$age <= age.1, ]))
    forks.2 = as.numeric(nrow(events[events$type == 'ForkEvent' & events$age <= age.2 & events$age > age.1, ]))
    forks.3 = as.numeric(nrow(events[events$type == 'ForkEvent' & events$age <= age.3 & events$age > age.2, ]))
    forks.4 = as.numeric(nrow(events[events$type == 'ForkEvent' & events$age <= age.4 & events$age > age.3, ]))
    forks.5 = as.numeric(nrow(events[events$type == 'ForkEvent' & events$age > age.4, ]))
    
  } else {
    subscribers.1 = subscribers.2 = subscribers.3 = subscribers.4 = subscribers.5 = subscribers.1_2 = subscribers.1_3 = subscribers.1_4 = 0
    forks.1 = forks.2 = forks.3 = forks.4 = forks.5 = forks.1_2 = forks.1_3 = forks.1_4 = 0
  }
  
  
  dataRow <- c(
    as.numeric(repo$github_id),as.character(repo$repository_name),as.character(repo$organization_name),as.numeric(repo$age),as.character(repo$language),as.logical(repo$is_top_project),
    nrow(code_contributions.1),nrow(code_contributions.2),nrow(code_contributions.3),nrow(code_contributions.4),nrow(code_contributions.5),
    as.numeric(code_contributions.ratio.1),as.numeric(code_contributions.ratio.2),as.numeric(code_contributions.ratio.3),as.numeric(code_contributions.ratio.4),as.numeric(code_contributions.ratio.5),
    as.numeric(subscribers.1),as.numeric(subscribers.2),as.numeric(subscribers.3),as.numeric(subscribers.4),as.numeric(subscribers.5),
    as.numeric(forks.1),as.numeric(forks.2),as.numeric(forks.3),as.numeric(forks.4),as.numeric(forks.5)
  )
  
  # Sys.sleep(1)
  
  observations[nrow(observations)+1,] <- dataRow
}

#write.csv(observations, file = "data/csv/calculated/time_obervations_in_section_code_and_events.csv", row.names = F, sep = ",")

observations <- read.csv("data/csv/calculated/time_obervations_in_section_code_and_events.csv", header = T, stringsAsFactors = F)

newDataFrame <- data.frame(repository.id = allContributions$github_id, forks_count = allContributions$forks_count, subscribers_count = allContributions$subscribers_count)

observations <- merge(observations, newDataFrame, by = c('repository.id'))
observations$forks.today <- observations$forks_count
observations$subscribers.today <- observations$subscribers_count

observations$age.0 <- 0
observations$age.1 <- age.1
observations$age.2 <- age.2
observations$age.3 <- age.3
observations$age.4 <- age.4
observations$age <- as.numeric(observations$age)
observations$is_top_project <- as.integer(observations$is_top_project)
observations$ratio.1 <- observations$code_contributions.ratio.1
observations$ratio.2 <- observations$code_contributions.ratio.2
observations$ratio.1_2 <- (observations$ratio.1 + observations$ratio.2) / 2
observations$ratio.3 <- observations$code_contributions.ratio.3
observations$ratio.2_3 <- (observations$ratio.2 + observations$ratio.3) / 2
observations$ratio.1_3 <- (observations$ratio.1 + observations$ratio.2 + observations$ratio.3) / 3
observations$ratio.4 <- observations$code_contributions.ratio.4
observations$ratio.3_4 <- (observations$ratio.4 + observations$ratio.4) / 2
observations$ratio.4_5 <- (observations$code_contributions.ratio.4 + observations$code_contributions.ratio.5) /2
observations$ratio.1_4 <- (observations$ratio.1 + observations$ratio.2 + observations$ratio.3 + observations$ratio.4) / 4

observations$forks.1_2 = ( observations$forks.1 + observations$forks.2 ) / 2
observations$forks.2_3 = ( observations$forks.2 + observations$forks.3 ) / 2
observations$forks.3_4 = ( observations$forks.3 + observations$forks.4 ) / 2
observations$forks.4_5 = ( observations$forks.4 + observations$forks.5 ) / 2

observations$subscribers.1_2 = ( observations$subscribers.1 + observations$subscribers.2 ) / 2
observations$subscribers.2_3 = ( observations$subscribers.2 + observations$subscribers.3 ) / 2
observations$subscribers.3_4 = ( observations$subscribers.3 + observations$subscribers.4 ) / 2
observations$subscribers.4_5 = ( observations$subscribers.4 + observations$subscribers.5 ) / 2


# observations <- subset(observations, observations$age <= age.max)

# library(xtable)
# columns <- c('subscribers.1','subscribers.2','subscribers.3','subscribers.4')
# xtable(summary(subset(observations, select=columns)))
#                   
#                                              ,
#                                              'subscribers.1','subscribers.2','subscribers.3','subscribers.4'))))
# print.xtable(summary(observations), file = "hypotheses/summary_age_effect.tex")

#write.table(observations, file = "data/csv/calculated/time_obervations_in_section_code_and_events.csv", sep=",", row.names=FALSE, col.names=T)

textFormat = "latex"
textFormat = "text"

linear.1 <- glm(formula = is_top_project ~ age + ratio.1, family=binomial(link='logit'), data = observations )
linear.2 <- glm(formula = is_top_project ~ age + ratio.2, family=binomial(link='logit'), data = observations )
linear.3 <- glm(formula = is_top_project ~ age + ratio.3, family=binomial(link='logit'), data = observations )
linear.4 <- glm(formula = is_top_project ~ age + ratio.4, family=binomial(link='logit'), data = observations )

content <- stargazer(linear.1, linear.2, linear.3, linear.4, type=textFormat, float = F)
toFile(content, file = 'hypotheses/h2_glm_top_project_ratio.tex')

linear.1 <- glm(formula = is_top_project ~ age + subscribers.1, family=binomial(link='logit'), data = observations )
linear.2 <- glm(formula = is_top_project ~ age + subscribers.2, family=binomial(link='logit'), data = observations )
linear.3 <- glm(formula = is_top_project ~ age + subscribers.3, family=binomial(link='logit'), data = observations )
linear.4 <- glm(formula = is_top_project ~ age + subscribers.4, family=binomial(link='logit'), data = observations )
linear.5 <- glm(formula = is_top_project ~ age + subscribers.5, family=binomial(link='logit'), data = observations )
linear.6 <- glm(formula = is_top_project ~ age + subscribers.today, family=binomial(link='logit'), data = observations )

content <- stargazer(linear.1, linear.2, linear.3, linear.4, linear.5, linear.6, type=textFormat, float = F)
toFile(content, file = 'hypotheses/h2_glm_top_project_subscribers.tex')

# linear.1 <- glm(formula = is_top_project ~ age + subscribers.1_2, family=binomial(link='logit'), data = observations )
# linear.2 <- glm(formula = is_top_project ~ age + subscribers.2_3, family=binomial(link='logit'), data = observations )
# linear.3 <- glm(formula = is_top_project ~ age + subscribers.3_4, family=binomial(link='logit'), data = observations )
# linear.4 <- glm(formula = is_top_project ~ age + subscribers.4_5, family=binomial(link='logit'), data = observations )
# 
# content <- stargazer(linear.1, linear.2, linear.3, linear.4, type=textFormat, float = F)
# toFile(content, file = 'hypotheses/h2_glm_top_project_subscribers_time_periods.tex')

linear.1 <- glm(formula = is_top_project ~ age + forks.1, family=binomial(link='logit'), data = observations )
linear.2 <- glm(formula = is_top_project ~ age + forks.2, family=binomial(link='logit'), data = observations )
linear.3 <- glm(formula = is_top_project ~ age + forks.3, family=binomial(link='logit'), data = observations )
linear.4 <- glm(formula = is_top_project ~ age + forks.4, family=binomial(link='logit'), data = observations )
linear.5 <- glm(formula = is_top_project ~ age + forks.5, family=binomial(link='logit'), data = observations )
linear.6 <- glm(formula = is_top_project ~ age + forks.today, family=binomial(link='logit'), data = observations )

content <- stargazer(linear.1, linear.2, linear.3, linear.4, linear.5, linear.6, type=textFormat, float = F)
toFile(content, file = 'hypotheses/h2_glm_top_project_forks.tex')

linear.1 <- glm(formula = is_top_project ~ age + forks.1_2, family=binomial(link='logit'), data = observations )
linear.2 <- glm(formula = is_top_project ~ age + forks.2_3, family=binomial(link='logit'), data = observations )
linear.3 <- glm(formula = is_top_project ~ age + forks.3_4, family=binomial(link='logit'), data = observations )
linear.4 <- glm(formula = is_top_project ~ age + forks.4_5, family=binomial(link='logit'), data = observations )

content <- stargazer(linear.1, linear.2, linear.3, linear.4, type=textFormat, float = F)
toFile(content, file = 'hypotheses/h2_glm_top_project_forks_time_periods.tex')



textFormat = "text"
linear.1 <- glm(formula = forks.1 ~ age + ratio.1, data = observations )
linear.2 <- glm(formula = forks.2 ~ age + ratio.2, data = observations )
linear.3 <- glm(formula = forks.3 ~ age + ratio.3, data = observations )
linear.4 <- glm(formula = forks.4 ~ age + ratio.4, data = observations )
linear.5 <- glm(formula = forks.2 ~ age + ratio.1, data = observations )
linear.6 <- glm(formula = forks.3 ~ age + ratio.2, data = observations )
linear.7 <- glm(formula = forks.4 ~ age + ratio.3, data = observations )
linear.8 <- glm(formula = forks.5 ~ age + ratio.4, data = observations )
linear.9 <- glm(formula = forks.3 ~ age + ratio.1, data = observations )
linear.10 <- glm(formula = forks.4 ~ age + ratio.2, data = observations )
linear.11 <- glm(formula = forks.5 ~ age + ratio.3, data = observations )

content <- stargazer(linear.1, linear.2, linear.3, linear.4, linear.5, linear.6, linear.7, linear.8, linear.9, linear.10, linear.11, type=textFormat, float = F)
toFile(content, file = 'hypotheses/h2_glm_forks_ratio_delayed.tex')



linear.1 <- glm(formula = subscribers.1 ~ age + ratio.1, data = observations )
linear.2 <- glm(formula = subscribers.2 ~ age + ratio.2, data = observations )
linear.3 <- glm(formula = subscribers.3 ~ age + ratio.3, data = observations )
linear.4 <- glm(formula = subscribers.4 ~ age + ratio.4, data = observations )
linear.5 <- glm(formula = subscribers.2 ~ age + ratio.1, data = observations )
linear.6 <- glm(formula = subscribers.3 ~ age + ratio.2, data = observations )
linear.7 <- glm(formula = subscribers.4 ~ age + ratio.3, data = observations )
linear.8 <- glm(formula = subscribers.5 ~ age + ratio.4, data = observations )
linear.9 <- glm(formula = subscribers.3 ~ age + ratio.1, data = observations )
linear.10 <- glm(formula = subscribers.4 ~ age + ratio.2, data = observations )
linear.11 <- glm(formula = subscribers.5 ~ age + ratio.3, data = observations )

content <- stargazer(linear.1, linear.2, linear.3, linear.4, linear.5, linear.6, linear.7, linear.8, linear.9, linear.10, linear.11, type=textFormat, float = F)
toFile(content, file = 'hypotheses/h2_glm_subscribers_ratio_delayed.tex')



linear.1 <- glm(formula = forks.2 ~ age + ratio.1, data = observations )
linear.2 <- glm(formula = forks.3 ~ age + ratio.2, data = observations )
linear.3 <- glm(formula = forks.4 ~ age + ratio.3, data = observations )
linear.4 <- glm(formula = forks.5 ~ age + ratio.4, data = observations )

linear.5 <- glm(formula = forks.1 ~ age + ratio.1, data = observations )
linear.6 <- glm(formula = forks.2 ~ age + ratio.2, data = observations )
linear.7 <- glm(formula = forks.3 ~ age + ratio.3, data = observations )
linear.8 <- glm(formula = forks.4 ~ age + ratio.4, data = observations )

linear.9  <- glm(formula = forks.3 ~ age + ratio.1, data = observations )
linear.10 <- glm(formula = forks.4 ~ age + ratio.2, data = observations )
linear.11 <- glm(formula = forks.5 ~ age + ratio.3, data = observations )
linear.12 <- glm(formula = forks.2_3 ~ age + ratio.1_2, data = observations )
linear.13 <- glm(formula = forks.3_4 ~ age + ratio.2_3, data = observations )
linear.14 <- glm(formula = forks.4_5 ~ age + ratio.3_4, data = observations )

# content <- stargazer(linear.1, linear.2, linear.3, linear.4, type=textFormat, float = F)
# toFile(content, file = 'hypotheses/h2_glm_forks_ratio_delayed.tex')
# content <- stargazer(linear.5, linear.6, linear.7, linear.8, type=textFormat, float = F)
# toFile(content, file = 'hypotheses/h2_glm_forks_ratio.tex')
# content <- stargazer(linear.9, linear.10, linear.11, linear.12, linear.13, linear.14, type=textFormat, float = F)
# toFile(content, file = 'hypotheses/h2_glm_forks_ratio_delay_time_period.tex')

## WICHTIG!

linear.1  <- glm(formula = forks.today ~ age + ratio.1_2, data = observations )
linear.2  <- glm(formula = forks.today ~ age + ratio.2_3, data = observations )
linear.3  <- glm(formula = forks.today ~ age + ratio.3_4, data = observations )
linear.4  <- glm(formula = forks.today ~ age + ratio.4_5, data = observations )
content <- stargazer(linear.1, linear.2, linear.3, linear.4, type=textFormat, float = F)
toFile(content, file = 'hypotheses/h2_glm_forks_today_ratio_period.tex')

linear.1  <- glm(formula = subscribers.today ~ age + ratio.1_2, data = observations )
linear.2  <- glm(formula = subscribers.today ~ age + ratio.2_3, data = observations )
linear.3  <- glm(formula = subscribers.today ~ age + ratio.3_4, data = observations )
linear.4  <- glm(formula = subscribers.today ~ age + ratio.4_5, data = observations )
content <- stargazer(linear.1, linear.2, linear.3, linear.4, type=textFormat, float = F)
toFile(content, file = 'hypotheses/h2_glm_subscribers_today_ratio_period.tex')

linear.1  <- glm(formula = forks.today ~ age + ratio.1, data = observations )
linear.2  <- glm(formula = forks.today ~ age + ratio.2, data = observations )
linear.3  <- glm(formula = forks.today ~ age + ratio.3, data = observations )
linear.4  <- glm(formula = forks.today ~ age + ratio.4, data = observations )
content <- stargazer(linear.1, linear.2, linear.3, linear.4, type=textFormat, float = F)
toFile(content, file = 'hypotheses/h2_glm_forks_today_ratio.tex')

linear.1  <- glm(formula = subscribers.today ~ age + ratio.1, data = observations )
linear.2  <- glm(formula = subscribers.today ~ age + ratio.2, data = observations )
linear.3  <- glm(formula = subscribers.today ~ age + ratio.3, data = observations )
linear.4  <- glm(formula = subscribers.today ~ age + ratio.4, data = observations )
content <- stargazer(linear.1, linear.2, linear.3, linear.4, type=textFormat, float = F)
toFile(content, file = 'hypotheses/h2_glm_subscribers_today_ratio.tex')










## Mixed Effect
textFormat = "text"

mixedeffect.1 <- lmer(formula = is_top_project ~ age + ratio.1 + (1 | organization.name), family=binomial(link='logit'), data = observations)
mixedeffect.2 <- lmer(formula = is_top_project ~ age + ratio.2 + (1 | organization.name), family=binomial(link='logit'), data = observations)
mixedeffect.3 <- lmer(formula = is_top_project ~ age + ratio.3 + (1 | organization.name), family=binomial(link='logit'), data = observations)
mixedeffect.4 <- lmer(formula = is_top_project ~ age + ratio.4 + (1 | organization.name), family=binomial(link='logit'), data = observations)

content <- stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, type=textFormat, float = F)

mixedeffect.1 <- lmer(formula = forks.2 ~ age + ratio.1 + (1 | organization.name), data = observations)
mixedeffect.2 <- lmer(formula = forks.3 ~ age + ratio.2 + (1 | organization.name), data = observations)
mixedeffect.3 <- lmer(formula = forks.4 ~ age + ratio.3 + (1 | organization.name), data = observations)
mixedeffect.4 <- lmer(formula = forks.5 ~ age + ratio.4 + (1 | organization.name), data = observations)

content <- stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, type=textFormat, float = F)

mixedeffect.1 <- lmer(formula = forks.1 ~ age + ratio.1 + (1 | organization.name), data = observations)
mixedeffect.2 <- lmer(formula = forks.2 ~ age + ratio.2 + (1 | organization.name), data = observations)
mixedeffect.3 <- lmer(formula = forks.3 ~ age + ratio.3 + (1 | organization.name), data = observations)
mixedeffect.4 <- lmer(formula = forks.4 ~ age + ratio.4 + (1 | organization.name), data = observations)

content <- stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, type=textFormat, float = F)

