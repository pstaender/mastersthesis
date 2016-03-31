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