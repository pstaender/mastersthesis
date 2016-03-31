#!/bin/bash

cd scripts && coffee merge_top_to_all_repositories.coffee > ../data/csv/_all_organizations_repositories.csv
# replace with new file
mv ../data/csv/all_organizations_repositories.csv ../data/csv/all_organizations_repositories.csv.backup
mv ../data/csv/_all_organizations_repositories.csv ../data/csv/all_organizations_repositories.csv
