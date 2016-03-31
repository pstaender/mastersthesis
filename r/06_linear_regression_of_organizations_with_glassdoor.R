#------------------------------------------------------------------#
#
# Time series data of repositories log files, watch and fork events
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
source('r/include_subsetvalues.R')
source('r/include_linear_regression_plots.R')

subsetData = T

# load the generated CSV file with all popular repositories for all 10 programming languges:
allContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T)
allContributions$all_issues_count <- allContributions$closed_issues_count + allContributions$open_issues_count

source('r/include_glassdoor_firms.R')

relevantFirms <- glassdoor
relevantFirms <- relevantFirms[glassdoor$numberOfRatings >= 38, ] # 38
relevantFirms <- relevantFirms[relevantFirms$number_of_distinct_repos >= 10, ]
# relevantFirms <- relevantFirms[relevantFirms$overallRating >= 3, ]
relevantFirms <- relevantFirms[relevantFirms$average_ratio_top > 0, ]
relevantFirms <- relevantFirms[relevantFirms$average_ratio_residual > 0, ]

## Fitting linear model (OLS) ####

library(nlme)
library(lattice)

linear.1 <- lm(overallRating ~ 
                 average_ratio_top +
                 average_ratio_residual +
                 numberOfRatings +
                 overallRating +
                 cultureAndValuesRating +
                 workLifeBalanceRating +
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
                  number_of_distinct_repos +
                  residual_repos
                , data = relevantFirms
)

linear.7a <- lm(average_ratio_top ~ 
                  average_ratio_top +
                  average_ratio_residual +
                  numberOfRatings +
                  overallRating +
                  cultureAndValuesRating +
                  workLifeBalanceRating +
                  number_of_distinct_repos +
                  residual_repos
                , data = relevantFirms
)


linear.7b <- lm(average_ratio_residual ~ 
                  average_ratio_top +
                  average_ratio_residual +
                  numberOfRatings +
                  overallRating +
                  cultureAndValuesRating +
                  workLifeBalanceRating +
                  number_of_distinct_repos +
                  residual_repos
                , data = relevantFirms
)




content = stargazer(
  linear.1, 
  linear.2,
  # linear.3a,
  #   linear.3b,
  #   linear.4,
  linear.5,
  linear.6a,
  linear.7a,
  linear.7b,
  type = "latex",
  float = F
)
write(content, file = "~/summary.tex")

content = stargazer(
  linear.1, 
  linear.2,
  # linear.3a,
  #   linear.3b,
  #   linear.4,
  linear.5,
  linear.6a,
  linear.7a,
  linear.7b,
  type = "text",
  float = F
)
write(content, file = "~/summary.md")