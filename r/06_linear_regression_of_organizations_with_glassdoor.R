#------------------------------------------------------------------#
#
# Linear regression with Glassdoor ratings and
# firms' open source commitments
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
source('r/include_subsetvalues.R')
source('r/include_linear_regression_plots.R')


#library(car)

subsetData = T

# load the generated CSV file with all popular repositories for all 10 programming languges:
allContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T)
allContributions$all_issues_count <- allContributions$closed_issues_count + allContributions$open_issues_count 

firms <- read.csv('data/csv/commercial_classification/commercial_classification_of_organizations.csv')
firms$glassdoor_name <- sapply(firms$glassdoor_name, toString)
glassdoor <- read.csv('data/csv/organizations_glassdoor.csv')



# firms <- subset(firms, typeof(glassdoor_name) == 'character')#firms[firms$glassdoor_name == 'amazon',]
# firms <- firms[nchar(firms$glassdoor_name) > 0,]
glassdoor$average_ratio_top <- 0
glassdoor$average_ratio_residual <- 0
glassdoor$closed_issues_count <- 0
glassdoor$open_issues_count <- 0
glassdoor$stargazers_count <- 0
glassdoor$contributors_count <- 0
glassdoor$subscribers_count <- 0

for (firm in glassdoor$login) {
  glassdoor[glassdoor$login == firm, ]$average_ratio_top <- mean(allContributions[(allContributions$organization_name == firm & allContributions$is_top_project == T),]$ratio)
  glassdoor[glassdoor$login == firm, ]$average_ratio_residual <- mean(allContributions[(allContributions$organization_name == firm & allContributions$is_top_project == F),]$ratio)
  #   glassdoor[glassdoor$login == firm, ]$stargazers_count <- sum(allContributions[allContributions$organization_name == firm,]$stargazers_count) / glassdoor[glassdoor$login == firm, ]$public_repos
  #   glassdoor[glassdoor$login == firm, ]$closed_issues_count <- sum(allContributions[allContributions$organization_name == firm,]$closed_issues_count) / glassdoor[glassdoor$login == firm, ]$public_repos
  #   glassdoor[glassdoor$login == firm, ]$open_issues_count <- sum(allContributions[allContributions$organization_name == firm,]$open_issues_count) / glassdoor[glassdoor$login == firm, ]$public_repos
  #   glassdoor[glassdoor$login == firm, ]$contributors_count <- sum(allContributions[allContributions$organization_name == firm,]$contributors_count) / glassdoor[glassdoor$login == firm, ]$public_repos
  #   glassdoor[glassdoor$login == firm, ]$subscribers_count <- sum(allContributions[allContributions$organization_name == firm,]$subscribers_count) / glassdoor[glassdoor$login == firm, ]$public_repos
}
# glassdoor$residual_repos <- 0
glassdoor$residual_repos = glassdoor$public_repos - glassdoor$number_of_distinct_repos
glassdoor$created_at = as.Date(as.character(glassdoor$created_at), format = "%Y-%m-%dT%H:%M:%SZ")
glassdoor$updated_at = as.Date(as.character(glassdoor$updated_at), format = "%Y-%m-%dT%H:%M:%SZ")
# calculate age in days
glassdoor$age = round((Sys.Date() - glassdoor$created_at), digits = 2)

relevantFirms <- glassdoor[glassdoor$numberOfRatings >= 38, ] # 38
relevantFirms <- relevantFirms[relevantFirms$number_of_distinct_repos >= 10, ]
# relevantFirms <- relevantFirms[relevantFirms$overallRating >= 3, ]
relevantFirms <- relevantFirms[relevantFirms$average_ratio_top > 0, ]
relevantFirms <- relevantFirms[relevantFirms$average_ratio_residual > 0, ]

## 2. Fitting linear model (OLS) ####

library(nlme)
library(lattice)

linear.1 <- lm(overallRating ~ 
                 average_ratio_top +
                 average_ratio_residual +
                 numberOfRatings +
                 overallRating +
                 cultureAndValuesRating +
                 workLifeBalanceRating +
                 age +
                 number_of_distinct_repos +
                 residual_repos
               , data = relevantFirms
)
linear.2 <- lm(number_of_distinct_repos ~ 
                 average_ratio_top +
                 average_ratio_residual +
                 numberOfRatings +
                 overallRating +
                 cultureAndValuesRating +
                 workLifeBalanceRating +
                 age +
                 number_of_distinct_repos +
                 residual_repos
               , data = relevantFirms
)

linear.3a <- lm(average_ratio_top ~ 
                  average_ratio_top +
                  average_ratio_residual +
                  numberOfRatings +
                  overallRating +
                  cultureAndValuesRating +
                  workLifeBalanceRating +
                  age +
                  number_of_distinct_repos +
                  residual_repos
                , data = relevantFirms
)

linear.3b <- lm(average_ratio_residual ~ 
                  average_ratio_top +
                  average_ratio_residual +
                  numberOfRatings +
                  overallRating +
                  cultureAndValuesRating +
                  workLifeBalanceRating +
                  age +
                  number_of_distinct_repos +
                  residual_repos
                , data = relevantFirms
)


linear.4 <- lm(public_repos ~ 
                 average_ratio_top +
                 average_ratio_residual +
                 numberOfRatings +
                 overallRating +
                 cultureAndValuesRating +
                 workLifeBalanceRating +
                 age +
                 number_of_distinct_repos +
                 residual_repos
               , data = relevantFirms
)

linear.5 <- lm(numberOfRatings ~ 
                 average_ratio_top +
                 average_ratio_residual +
                 numberOfRatings +
                 overallRating +
                 cultureAndValuesRating +
                 workLifeBalanceRating +
                 age +
                 number_of_distinct_repos +
                 residual_repos
               , data = relevantFirms
)

linear.6a <- lm(workLifeBalanceRating ~ 
                  average_ratio_top +
                  average_ratio_residual +
                  numberOfRatings +
                  overallRating +
                  cultureAndValuesRating +
                  workLifeBalanceRating +
                  age +
                  number_of_distinct_repos +
                  residual_repos
                , data = relevantFirms
)



linear.7a <- lm(stargazers_count ~ 
                  average_ratio_top +
                  average_ratio_residual +
                  numberOfRatings +
                  overallRating +
                  cultureAndValuesRating +
                  workLifeBalanceRating +
                  age +
                  number_of_distinct_repos +
                  residual_repos +
                  stargazers_count +
                  contributors_count +
                  subscribers_count
                , data = relevantFirms
)

content = stargazer(
  linear.1, 
  linear.2,
  linear.5,
  linear.6a,
  linear.7a,
  type = "latex",
  float = F
)
write(content, file = "tables/firm_rating_and_open_source_contribution.tex")
