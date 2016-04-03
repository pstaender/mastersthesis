#------------------------------------------------------------------#
#
# H1: Linear regression Code Contribution
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
source('r/include_linear_regression_plots.R')

resultFolderName <- 'statistics/code_contribution/'

outputDataToFile = T

# load the generated CSV file with all popular repositories for all 10 programming languges:
allContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T)
allContributions$all_issues_count <- allContributions$closed_issues_count + allContributions$open_issues_count
allContributions$top_repo <- as.integer(allContributions$is_top_project)
allContributions$external_commits_count <- allContributions$all_commits_count - allContributions$internal_commits_count
allContributions$popularity <- allContributions$stargazers_count * allContributions$subscribers_count * allContributions$forks_count * allContributions$all_issues_count

firms <- organizations

contributions <- allContributions

contributions <- subset(contributions, contributions$language %in% OBSERVED_LANGUAGES)

# if (isTRUE(outputDataToFile)) {
#   dir.create(paste0(resultFolderName, sessionID), showWarnings = TRUE, recursive = FALSE)
# }


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

formatType = "text"#"latex"

## Generalized Linear Model ####
# Leave organizations out

## H 1: Firm employees' participation affect the participation of external developers
## H 1.1: If firm employees' contribute more-often source code, external developers do as well}

contribs <- contributions
contribs$`int. commits` <- contribs$internal_commits_count
contribs$`ext. commits` <- contribs$external_commits_count

#plot(rank(contribs$`int. commits`), rank(contribs$`ext. commits`))
#contribs <- subset(contribs, contribs$language == 'JavaScript')
#cor((contribs$`int. commits`), (contribs$`ext. commits`), method="spearman")
#cor((contribs$`int. commits`), (contribs$`ext. commits`), method="kendall")
#cor((contribs$`int. commits`), (contribs$`ext. commits`))

# contribs <- subset(contribs, contribs$internal_commits_count < 300)
# contribs <- subset(contribs, contribs$external_commits_count < 300)
# contribs <- subset(contribs, contribs$internal_commits_count > 20)
# contribs <- subset(contribs, contribs$external_commits_count > 20)


#mixedeffect.1 <- lmer(formula = external_commits_count ~ internal_commits_count + (1 | organization_name) + (1 | language), data = contribs)
#mixedeffect.2 <- lmer(formula = internal_commits_count ~ external_commits_count + (1 | organization_name) + (1 | language), data = contribs)

viewedContributions <- contribs
viewedContributions <- subset(viewedContributions, viewedContributions$`ext. commits` < 2000)
viewedContributions <- subset(viewedContributions, viewedContributions$`int. commits` < 2000)
viewedContributions <- subset(viewedContributions, viewedContributions$`ext. commits` > 10)
viewedContributions <- subset(viewedContributions, viewedContributions$`int. commits` > 10)


linear.1 <- lm(formula = `ext. commits` ~ `int. commits`, data = contribs)
linear.2 <- lm(formula = `int. commits` ~ `ext. commits`, data = contribs)
linear.3 <- lm(formula = `ext. commits` ~ `int. commits`, data = contribs[contribs$is_top_project == T,])
linear.4 <- lm(formula = `int. commits` ~ `ext. commits`, data = contribs[contribs$is_top_project == T,])
linear.5 <- lm(formula = `ext. commits` ~ `int. commits`, data = contribs[contribs$is_top_project == F,])
linear.6 <- lm(formula = `int. commits` ~ `ext. commits`, data = contribs[contribs$is_top_project == F,])
linear.7 <- lm(formula = `ext. commits` ~ `int. commits`, data = contribs[contribs$is_top_project == T & contribs$age >= 365,])
linear.8 <- lm(formula = `int. commits` ~ `ext. commits`, data = contribs[contribs$is_top_project == T & contribs$age >= 365,])
linear.9 <- lm(formula = `ext. commits` ~ `int. commits`, data = contribs[contribs$is_top_project == F & contribs$age >= 365,])
linear.10 <- lm(formula = `int. commits` ~ `ext. commits`, data = contribs[contribs$is_top_project == F & contribs$age >= 365,])
linear.11 <- lm(formula = `ext. commits` ~ `int. commits`, data = contribs[contribs$is_top_project == T & contribs$age < 365,])
linear.12 <- lm(formula = `int. commits` ~ `ext. commits`, data = contribs[contribs$is_top_project == T & contribs$age < 365,])
linear.13 <- lm(formula = `ext. commits` ~ `int. commits`, data = contribs[contribs$is_top_project == F & contribs$age < 365,])
linear.14 <- lm(formula = `int. commits` ~ `ext. commits`, data = contribs[contribs$is_top_project == F & contribs$age < 365,])

content <- stargazer(linear.1, linear.2, linear.3, linear.4, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_internal_external_commits_count_subset.1.tex')
}
content <- stargazer(linear.5, linear.6, linear.7, linear.8, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_internal_external_commits_count_subset.2.tex')
}
content <- stargazer(linear.9, linear.10, linear.11, linear.12, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_internal_external_commits_count_subset.3.tex')
}
content <- stargazer(linear.13, linear.14, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_internal_external_commits_count_subset.4.tex')
}

slope.1 <- linear.1
slope.2 <- linear.2
ggplot(data = viewedContributions, legend=TRUE, aes(`int. commits`, `ext. commits`)) +
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




## H1.2: Issues ###

issues <- read.csv(paste0("data/csv/calculated/issue_ratio.csv"), header = T, stringsAsFactors = F)
allContributions$repository.id <- allContributions$github_id
issues <- merge(issues, allContributions, by=c('repository.id'))

issues$issues_count_by_external_developer <- issues$issues_issuescomments_count - issues$issues_count_by_firm_employed_developer
issues <- subset(issues, issues$language %in% OBSERVED_LANGUAGES)

linear.1 <- lm(formula = issues_count_by_external_developer ~ issues_count_by_firm_employed_developer, data = issues)
linear.2 <- lm(formula = issues_count_by_firm_employed_developer ~ issues_count_by_external_developer, data = issues)
linear.3 <- lm(formula = issues_count_by_external_developer ~ issues_count_by_firm_employed_developer, data = issues[issues$is_top_project.x == T,])
linear.4 <- lm(formula = issues_count_by_firm_employed_developer ~ issues_count_by_external_developer, data = issues[issues$is_top_project.x == T,])
linear.5 <- lm(formula = issues_count_by_external_developer ~ issues_count_by_firm_employed_developer, data = issues[issues$is_top_project.x == F,])
linear.6 <- lm(formula = issues_count_by_firm_employed_developer ~ issues_count_by_external_developer, data = issues[issues$is_top_project.x == F,])
linear.7 <- lm(formula = issues_count_by_external_developer ~ issues_count_by_firm_employed_developer, data = issues[issues$is_top_project.x == T & issues$age >= 365,])
linear.8 <- lm(formula = issues_count_by_firm_employed_developer ~ issues_count_by_external_developer, data = issues[issues$is_top_project.x == T & issues$age >= 365,])
linear.9 <- lm(formula = issues_count_by_external_developer ~ issues_count_by_firm_employed_developer, data = issues[issues$is_top_project.x == F & issues$age >= 365,])
linear.10 <- lm(formula = issues_count_by_firm_employed_developer ~ issues_count_by_external_developer, data = issues[issues$is_top_project.x == F & issues$age >= 365,])
linear.11 <- lm(formula = issues_count_by_external_developer ~ issues_count_by_firm_employed_developer, data = issues[issues$is_top_project.x == T & issues$age < 365,])
linear.12 <- lm(formula = issues_count_by_firm_employed_developer ~ issues_count_by_external_developer, data = issues[issues$is_top_project.x == T & issues$age < 365,])
linear.13 <- lm(formula = issues_count_by_external_developer ~ issues_count_by_firm_employed_developer, data = issues[issues$is_top_project.x == F & issues$age < 365,])
linear.14 <- lm(formula = issues_count_by_firm_employed_developer ~ issues_count_by_external_developer, data = issues[issues$is_top_project.x == F & issues$age < 365,])

content <- stargazer(linear.1, linear.2, linear.3, linear.4, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_internal_external_issues.1.tex')
}
content <- stargazer(linear.5, linear.6, linear.7, linear.8, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_internal_external_issues.2.tex')
}
content <- stargazer(linear.9, linear.10, linear.11, linear.12, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_internal_external_issues.3.tex')
}
content <- stargazer(linear.13, linear.14, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_internal_external_issues.4.tex')
}
stargazer(linear.1, linear.2, linear.3, linear.4, linear.5, linear.6, linear.7, linear.8, linear.9, linear.10, linear.11, linear.12, linear.13, linear.14, type="text")

slope.1 <- linear.11
slope.2 <- linear.12
viewedIssues <- issues
viewedIssues <- subset(viewedIssues, viewedIssues$issues_count_by_firm_employed_developer < 100)
viewedIssues <- subset(viewedIssues, viewedIssues$issues_count_by_external_developer < 1500)
ggplot(data = viewedIssues, legend=TRUE, aes(issues_count_by_firm_employed_developer, issues_count_by_external_developer)) +
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


# h1.2_issue_comments_residual
## H1.2: Issues Comments ###
issuesComments <- read.csv(paste0("data/csv/calculated/issue_comment_ratio.csv"), header = T, stringsAsFactors = F)
issuesComments <- subset(issuesComments, issuesComments$repository.id %in% issues$repository.id)
issuesComments$comments_count_by_ext <- issuesComments$issues_issuescomments_count - issuesComments$issues_count_by_firm_employed_developer
observedIssuesComments <- issuesComments
# observedIssuesComments <- subset(observedIssuesComments, issuesComments$is_top_project == T)
observedIssuesComments$comments_count_by_int <- observedIssuesComments$issues_count_by_firm_employed_developer


linear.1 <- lm(formula = issues_issuescomments_count ~ content_share_by_firm_employed_developer, data = observedIssuesComments)
linear.2 <- lm(formula = comments_count_by_ext ~ content_share_by_firm_employed_developer, data = observedIssuesComments)
linear.3 <- lm(formula = comments_count_by_ext ~ comments_count_by_int, data = observedIssuesComments)
linear.4 <- lm(formula = comments_count_by_int ~ comments_count_by_ext, data = observedIssuesComments)
content = stargazer(linear.1, linear.2, linear.3, linear.4, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_issues_comments_all.tex')
}
linear.5 <- lm(formula = issues_issuescomments_count ~ content_share_by_firm_employed_developer, data = subset(observedIssuesComments, issuesComments$is_top_project == TRUE))
linear.6 <- lm(formula = comments_count_by_ext ~ content_share_by_firm_employed_developer, data = subset(observedIssuesComments, issuesComments$is_top_project == TRUE))
linear.7 <- lm(formula = comments_count_by_ext ~ comments_count_by_int, data = subset(observedIssuesComments, issuesComments$is_top_project == TRUE))
linear.8 <- lm(formula = comments_count_by_int ~ comments_count_by_ext, data = subset(observedIssuesComments, issuesComments$is_top_project == TRUE))
content = stargazer(linear.5, linear.6, linear.7, linear.8, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_issues_comments_top.tex')
}

linear.9 <- lm(formula = issues_issuescomments_count ~ content_share_by_firm_employed_developer, data = subset(observedIssuesComments, issuesComments$is_top_project == FALSE))
linear.10 <- lm(formula = comments_count_by_ext ~ content_share_by_firm_employed_developer, data = subset(observedIssuesComments, issuesComments$is_top_project == FALSE))
linear.11 <- lm(formula = comments_count_by_ext ~ comments_count_by_int, data = subset(observedIssuesComments, issuesComments$is_top_project == FALSE))
linear.12 <- lm(formula = comments_count_by_int ~ comments_count_by_ext, data = subset(observedIssuesComments, issuesComments$is_top_project == FALSE))
content = stargazer(linear.9, linear.10, linear.11, linear.12, type=formatType, float = F)
if (isTRUE(outputDataToFile)) {
  write(content, file = 'hypotheses/h1_issues_comments_residual.tex')
}

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
