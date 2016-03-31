#!/bin/bash

# get license information and contributors

targetFolder="../data/apidata/repositories"
trap "exit" INT

cd scripts

repositories=$(cat ../data/csv/all_organizations_repositories.csv | coffee filter_csv.coffee --fields="full_name" --quote='')

counter=0

min=${1:-0}
max=${2:-100000}

for repo in $repositories;
do
  if [ "$counter" -ge $min ] && [ "$counter" -le $max ]; then
    dateTime=$(date +"%m-%d-%y %T")
    mkdir -p $targetFolder/$repo
    # replace '/' with '_'
    fname=$(echo $repo | sed "s/\\//_/")
    echo -e "[$counter] ($dateTime) $repo: \c"
    # get repo informaton
    # coffee github_api_repository_subdata_v2.coffee --url="repos/$repo" --header="Accept: 'application/vnd.github.drax-preview+json'" > $targetFolder/$repo/repository_$fname.json
    # # # get contributors (only first 500 possible)
    coffee github_api_repository_subdata_v2.coffee --url="/repos/$repo/contributors" > $targetFolder/$repo/contributors_$fname.json
    # sleep 1
    # get subscribers
    coffee github_api_repository_subdata_v2.coffee --url="/repos/$repo/subscribers" > $targetFolder/$repo/subscribers_$fname.json
    # sleep 1
  fi
  counter=$((counter+1))
done;
