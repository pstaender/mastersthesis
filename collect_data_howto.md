# How to collect all firms' and projects' data

You **don't** have to perform these steps to observe and analyze data in R. This is more a "log" how the data was collected and prepared for further processing in R.

## Observe int/ext ratio of repositories

  * get all top projects for each language (optional)
    - export OAUTHTOKEN=yourgithubauthtoken; shellscripts/search_top_projects.sh | sh
  * all json data to one csv file
    - ./shellscripts/top_projects_to_csv.sh > data/csv/top_repositories.csv
    - calls (--> scripts/api_search_results_to_csv.coffee)
  * Run R
    - r/01_installation_and_organization_selection.R
  * Get all repos
    - export OAUTHTOKEN=123; cd scripts && coffee github_api_repositories.coffee --csvFile=../data/csv/selected_commercial_organizations.csv | sh
    - ./shellscripts/all_repositories_to_csv.sh > csv/all_organizations_repositories.csv
  * Optional: Get all organization data (gets api data from GitHub, may take while), (over)writes file csv/organizations.csv
    - export OAUTHTOKEN=123; ./shellscripts/organization_data_from_github.sh
    - fill email_pattern column manually in generated csv/organizations.csv
  <!-- * mark popular projects
    - ./shellscripts/mark_popular_repositories.sh > csv/_all_organizations_repositories.csv -->
  * merge to one csv file
    - ./shellscripts/merge_top_to_all_repositories.sh
  * Get organization members and repo collaborators
  * Optional: get all issues for all repos from GitHub (takes ~6 hours depending on connection and the size of repository set)
    - export OAUTHTOKEN=123; ./shellscripts/get_issues_of_repos.sh &> ~/issues.log
    - you can start a specific counting position with (here `102`): ./shellscripts/get_issues_of_repos.sh 102
  * Optional: get additional data for repositories (license,contributors and subscribers), takes a while
    - export OAUTHTOKEN=123; ./shellscripts/get_repositories_complete_information.sh
  * git log to csv files (all repositories will be cloned to temporary folders - this may take a while, too)
    - ./shellscripts/logs_of_repos_to_csv.sh &> ~/gitlog.log
  * write additional repository information to one csv file (takes a while, ruby > 2 needed)
    - ruby ./shellscripts/repositories_as_csv.ruby > data/csv/repositories_details.csv
  * collect all authors
    - cd scripts; coffee collect_all_emails_of_contributions.coffee > ../data/csv/repositories/authors/all_organizations.csv
  * set manually email domain regex pattern on data/csv/commercial_classification/commercial_classification_of_organizations.csv
  * processing R scripts
    - 02_analyze_relevant_repositories.R
    - 03_contribution_ratios.R
    - 04_analyze_external_contributors.R
    - 05_*.R
  * collect all contributors from csv
    - cd scripts && coffee ./collect_potential_external_contributors.coffee --outputJSONFiles=true > ../data/csv/potential_firm_employed_contributors.csv
      - will (over)write files data/json/contributors_by_email.json & data/json/contributors_by_name.json
    - obsolete: ./shellscripts/all_contributors_as_csv.sh > data/csv/all_relevant_contributors.csv
  * merge glassdoor data with organization data
    - cd scripts && coffee merge_organization_with_glassdoor.coffee > ../data/csv/organizations_glassdoor.csv


## Issue Comments

  * Install required node modules and prepare shell to execute the script:
    - (sudo) npm install -g shelljs yargs glob progress nodemailer
    - `export NODE_PATH=/usr/lib/node_modules``` (linux) -or- `export NODE_PATH=/usr/local/lib/node_modules/` (mac)
  * Get all issues
    - ./shellscripts/get_all_issues_comments.sh

## Historical GitHub Data (from githubarchive)

  * Download all JSON files from https://www.githubarchive.org/ between 2011-2015 (~160GB)
    Ensure that the path are correct and (temp) folders exists; 160GB of free disk space is needed
    - ./shellscripts/get_history_githubprojects.sh
  * Extract all relevant repos from the data: (takes a while)
    - ./shellscripts/iterate_all_events.sh

  (previous / obsolete way:)
  * Extract Watch and Fork events (takes a while) and write it in two seperate json files (forks and watcher)
    - ./shellscripts/extract_repo_activities.sh
  * read history event for each (relevant) repo and write it to csv files (data/csv/repositories/forkevent|watchevent/)
    - ./shellscripts/events_of_repositories_to_csv_files.coffee --csvFile=../filtered_repo_activities.forkevent.json --event="ForkEvent"
    - ./shellscripts/events_of_repositories_to_csv_files.coffee --csvFile=../filtered_repo_activities.watchevent.json --event="WatchEvent"

## Bundle Issues and Issue Comments for deeper analyzes in CSV files
  * exec shell script (takes a while)
    - ./shellscripts/bundle_issues_and_comments.sh 2> ~/bundle_issues_and_comments.error.log 1> ~/bundle_issues_and_comments.log

## Export possible relevant github user from ghtorrent database
  * First import ghtorrent mysql database
  * run `mysql ghtorrent < data/sql%select_potential_firm_developers_from_ghtorrent.sql` and receive csv file
