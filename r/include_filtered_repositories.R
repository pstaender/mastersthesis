# load the generated CSV file with all popular repositories for all 10 programming languges:
repositories <- read.csv(paste0("data/csv/repositories_details.csv"), header = T, stringsAsFactors=FALSE)
allOrganizationsRepos <- read.csv("data/csv/all_organizations_repositories.csv", header = T, stringsAsFactors=FALSE)

# convert true | false to R boolean
repositories$is_top_repository <- as.logical(repositories$is_top_repository)
# convert date
repositories$created_at = as.Date(as.character(repositories$created_at), format = "%Y-%m-%dT%H:%M:%SZ")
repositories$updated_at = as.Date(as.character(repositories$updated_at), format = "%Y-%m-%dT%H:%M:%SZ")
# calculate age in days
repositories$age = round((repositories$updated_at - repositories$created_at), digits = 2)
# with more than 1 commits
repositories <- subset(repositories, repositories$commits_count > 1)
# more than 1 contributor
repositories <- subset(repositories, repositories$contributors_count > 1)
# older than 1 month
# repositories <- subset(repositories, repositories$age > 30)
# only top
# repositories <- subset(repositories, repositories$is_top_repository == T)
# set the filename
repositories$log_filename <- paste0('logs_', repositories$organization_name, '_', repositories$repository_name, '.csv')

# sort by $organizationlogin/$reponame
repositories <- repositories[order(repositories$full_name), ]

print("Info: (Filtered) Repositories are available as gobal `repositories`")
