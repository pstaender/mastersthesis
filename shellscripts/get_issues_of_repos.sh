#!/bin/bash
repos=$(cd scripts && coffee filter_csv.coffee --file=../data/csv/all_organizations_repositories.csv --fields="full_name" --delimiter="" --quote="")
trap "exit" INT
counter=0

min=${1:-0}
max=${2:-100000}

cd scripts
for repo in $repos; do
  # echo $counter
  if [ "$counter" -ge $min ] && [ "$counter" -le $max ]; then
    dateTime=$(date +"%m-%d-%y %T")
    fname=$(echo $repo | sed "s/\\//_/")
    mkdir -p ../data/apidata/repositories/$repo
    echo -e "[$counter] ($dateTime) $repo: \c"
    for status in open closed;
    do
      coffee github_api_repository_subdata_v2.coffee --endpoint="repos" --parameters="state: '$status'" --urlSegment="$repo" --subsegment="issues" --perPage=100 > ../data/apidata/repositories/$repo/issues_${status}_${fname}.json
      # sleep 1
    done
  fi
  counter=$((counter+1))
done;
