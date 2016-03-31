#------------------------------------------------------------------#
#
# Linear regression with mixed models
#
# * run `03_code_contribution_ratios.R` first
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

resultFolderName <- 'statistics/code_contribution/'

outputDataToFile = F

# load the generated CSV file with all popular repositories for all 10 programming languges:
allContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T)
allContributions$all_issues_count <- allContributions$closed_issues_count + allContributions$open_issues_count
allContributions$top_repo <- as.integer(allContributions$is_top_project)

firms <- organizations

contributions <- allContributions

contributions <- subset(contributions, contributions$language %in% OBSERVED_LANGUAGES)

# if (isTRUE(outputDataToFile)) {
#   dir.create(paste0(resultFolderName, sessionID), showWarnings = TRUE, recursive = FALSE)
# }

content <- stargazer(contributions)
filename = paste0(resultFolderName, sessionID, '/summary_contributions', '.tex')
#write(content, filename)

fileSuffix <- ''

# dummy variables for firms
for (firm in firms[,1]) {
  contributions[,firm] <- 0
  contributions[contributions$organization_name == toString(firm), firm] <- 1
}


# dummy variables for programming languages
for (language in programmingLanguages) {
  contributions[,toString(language)] <- 0
  contributions[contributions$language == toString(language), toString(language)] <- 1
}

contributions$firm_ <- contributions$organization_name
contributions$lang_ <- contributions$language

## Generalized Linear Model ####
# Leave organizations out

linear.1 <- glm(formula = stargazers_count ~ ratio + age, data = contributions )
linear.2 <- glm(formula = stargazers_count ~ ratio + age + lang_, data = contributions )
linear.3 <- glm(formula = stargazers_count ~ ratio + age + firm_, data = contributions )
linear.4 <- glm(formula = stargazers_count ~ ratio + age + firm_ + lang_, data = contributions )
linear.5 <- glm(formula = subscribers_count ~ ratio + age, data = contributions )
linear.6 <- glm(formula = subscribers_count ~ ratio + age + lang_, data = contributions )
linear.7 <- glm(formula = subscribers_count ~ ratio + age + firm_, data = contributions )
linear.8 <- glm(formula = subscribers_count ~ ratio + age + firm_ + lang_, data = contributions )
linear.9 <- glm(formula = forks_count ~ ratio + age , data = contributions)
linear.10 <- glm(formula = forks_count ~ ratio + age + lang_, data = contributions)
linear.11 <- glm(formula = forks_count ~ ratio + age + firm_, data = contributions)
linear.12 <- glm(formula = forks_count ~ ratio + age + firm_ + lang_, data = contributions)


slope.1 <- linear.7
# slope.2 <- mixedeffect.6

plotData <- contributions
# plotData <- subset(plotData, observedIssuesComments$comments_count_by_int < 2000)
# plotData <- subset(plotData, plotData$comments_count_by_ext < 10000)

ggplot(data = plotData, legend=TRUE, aes(ratio, subscribers_count)) +
  geom_point(pch = 19, alpha = 0.3) +
  guides(fill=guide_legend(title=NULL)) +
  # theme_classic() +
  xlab("Ratio") +
  ylab("Subscribers") +
  geom_abline(intercept = slope.1$coefficients[1],
              slope = slope.1$coefficients[2],
              size=0.9, color="#FFC748")
  # scale_y_continuous(limits = c(0, 50))
  # scale_x_continuous(limits = c(0.05, 0.95))

#   scale_y_continuous(limits = c(20, 400)) +
#   scale_x_continuous(limits = c(0.05, 0.95))
#
#   geom_abline(intercept = slope.2$,
#               slope = slope.2$coefficients[2],
#               size=0.9, lty="dashed", color = "blue")


content <- stargazer(linear.1, linear.2, linear.3, linear.4, linear.5, linear.6, linear.7, linear.8, linear.9, linear.11, linear.12, type="text", float = F)
write(content, file = 'tables/statistics_results/code_contribution_popularity_glm_dummy.tex')


slope.1 <- linear.3
slope.2 <- linear.4

plotData <- observedIssuesComments
plotData <- subset(plotData, observedIssuesComments$comments_count_by_int < 2000)
plotData <- subset(plotData, plotData$comments_count_by_ext < 10000)

ggplot(data = plotData, legend=TRUE, aes(comments_count_by_int, comments_count_by_ext)) +
  geom_point(pch = 19, alpha = 0.3) +
  guides(fill=guide_legend(title=NULL)) +
  # theme_classic() +
  ylab("") +
  xlab("") +
  geom_abline(intercept = slope.1$coefficients[1],
              slope = slope.1$coefficients[2],
              size=0.9, color="#FFC748") +
  geom_abline(intercept = slope.2$coefficients[1],
              slope = slope.2$coefficients[2],
              size=0.9, lty="dashed", color = "blue")

linear.1 <- glm(formula = all_issues_count ~ ratio + age , data = contributions)
linear.2 <- glm(formula = all_issues_count ~ ratio + age + lang_, data = contributions)
linear.3 <- glm(formula = all_issues_count ~ ratio + age + firm_, data = contributions)
linear.4 <- glm(formula = all_issues_count ~ ratio + age + firm_ + lang_, data = contributions)
linear.5 <- glm(formula = contributors_count ~ ratio + age , data = contributions)
linear.6 <- glm(formula = contributors_count ~ ratio + age + lang_, data = contributions)
linear.7 <- glm(formula = contributors_count ~ ratio + age + firm_, data = contributions)
linear.8 <- glm(formula = contributors_count ~ ratio + age + firm_ + lang_, data = contributions)
linear.9 <- glm(formula = top_repo ~ ratio + age , family=binomial(link='logit'), data = contributions )
linear.10 <- glm(formula = top_repo ~ ratio + age + lang_, family=binomial(link='logit'), data = contributions )
linear.11 <- glm(formula = top_repo ~ ratio + age + firm_, family=binomial(link='logit'), data = contributions )
linear.12 <- glm(formula = top_repo ~ ratio + age + firm_ + lang_, family=binomial(link='logit'), data = contributions )

content <- stargazer(linear.1, linear.2, linear.3, linear.4, linear.5, linear.6, linear.7, linear.8, linear.9, linear.11, linear.12, type="latex", float = F)
write(content, file = 'tables/statistics_results/code_contribution_others_glm_dummy.tex')

## Mixed-effect modeling

# group by organization
mixedeffect.1 <- lmer(formula = stargazers_count ~ ratio + age + (1 | organization_name), data = contributions)
mixedeffect.2 <- lmer(formula = subscribers_count ~ ratio + age + (1 | organization_name), data = contributions)
mixedeffect.3 <- lmer(formula = forks_count ~ ratio + age + (1 | organization_name), data = contributions)
mixedeffect.4 <- lmer(formula = all_issues_count ~ ratio + age + (1 | organization_name), data = contributions)
mixedeffect.5 <- lmer(formula = contributors_count ~ ratio + age + (1 | organization_name), data = contributions)
mixedeffect.6 <- lmer(formula = top_repo ~ ratio + age + (1 | organization_name), family=binomial(link='logit'), data = contributions)

content <- stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, mixedeffect.5, mixedeffect.6, type="text", float = F)
write(content, file = 'tables/statistics_results/code_contribution_mixed_effects_organizations.tex')

mixedeffect.1 <- lmer(formula = stargazers_count ~ ratio + age + (1 | organization_name) + (1 | language), data = contributions)
mixedeffect.2 <- lmer(formula = subscribers_count ~ ratio + age + (1 | organization_name) + (1 | language), data = contributions)
mixedeffect.3 <- lmer(formula = forks_count ~ ratio + age + (1 | organization_name) + (1 | language), data = contributions)
mixedeffect.4 <- lmer(formula = all_issues_count ~ ratio + age + (1 | organization_name) + (1 | language), data = contributions)
mixedeffect.5 <- lmer(formula = contributors_count ~ ratio + age + (1 | organization_name) + (1 | language), data = contributions)
mixedeffect.6 <- glmer(formula = top_repo ~ ratio + age + (1 | organization_name) + (1 | language), family=binomial(link='logit'), data = contributions)

content <- stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, mixedeffect.5, mixedeffect.6, type="text", float = F)
write(content, file = 'tables/statistics_results/code_contribution_mixed_effects_organizations_and_languages.tex')

mixedeffect.1 <- lmer(formula = ratio ~ stargazers_count + (1 | organization_name), data = contributions)
mixedeffect.2 <- lmer(formula = ratio ~ subscribers_count + (1 | organization_name), data = contributions)
mixedeffect.3 <- lmer(formula = ratio ~ forks_count + (1 | organization_name), data = contributions)
mixedeffect.4 <- lmer(formula = ratio ~ all_issues_count + (1 | organization_name), data = contributions)
mixedeffect.5 <- lmer(formula = ratio ~ contributors_count + (1 | organization_name), data = contributions)
mixedeffect.6 <- lmer(formula = ratio ~ top_repo + (1 | organization_name), data = contributions)

content <- stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, mixedeffect.5, mixedeffect.6, type="latex", float = F)
write(content, file = 'hypotheses/h3/influence_on_ratio_mixed_effect_orgs.tex')


mixedeffect.1 <- lmer(formula = ratio ~ stargazers_count + (1 | organization_name) + (1 | language), data = contributions)
mixedeffect.2 <- lmer(formula = ratio ~ subscribers_count + (1 | organization_name) + (1 | language), data = contributions)
mixedeffect.3 <- lmer(formula = ratio ~ forks_count + (1 | organization_name) + (1 | language), data = contributions)
mixedeffect.4 <- lmer(formula = ratio ~ all_issues_count + (1 | organization_name) + (1 | language), data = contributions)
mixedeffect.5 <- lmer(formula = ratio ~ contributors_count + (1 | organization_name) + (1 | language), data = contributions)
mixedeffect.6 <- lmer(formula = ratio ~ top_repo + (1 | organization_name) + (1 | language), data = contributions)

# content <- stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, mixedeffect.5, mixedeffect.6, type="text", float = F)
content <- stargazer(mixedeffect.1, mixedeffect.2, mixedeffect.3, mixedeffect.4, mixedeffect.5, mixedeffect.6, type="latex", float = F)
write(content, file = 'hypotheses/h3/influence_on_ratio_mixed_effect_orgs_langs.tex')
