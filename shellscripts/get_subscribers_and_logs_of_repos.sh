#!/bin/bash
repos=$(cd scripts && coffee filter_csv.coffee --file=../data/csv/all_organizations_repositories.csv --fields="full_name")

# repos=`cd ../scripts && coffee `

for repo in $repos; do
  echo ": $repo"
done;
