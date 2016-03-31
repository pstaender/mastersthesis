#!/bin/bash

echo "Deactivated because the (free) SQL quotas aren't enough to query the requested data"
exit(1)
# SELECT repository_watchers, created_at FROM [githubarchive:github.timeline]
# WHERE repository_url = 'facebook/react-native';

#!/bin/bash
repos=$(cd scripts && coffee filter_csv.coffee --file=../data/csv/all_organizations_repositories.csv --fields="full_name" --delimiter="" --quote="")
trap "exit" INT
counter=0

min=${1:-0}
max=${2:-100000}


# table=""
# cd scripts
for repo in $repos; do
  if [ "$counter" -ge $min ] && [ "$counter" -le $max ]; then
    dateTime=$(date +"%m-%d-%y %T")
    # echo $repo
    fname=$(echo $repo | sed "s/\\//_/")
    # mkdir -p ../data/apidata/repositories/$repo
    echo -e "[$counter] ($dateTime) Exec BQ for $repo: \c"
    bq --quiet --headless --format=csv query "SELECT type, repository_watchers, created_at, repository_url FROM [githubarchive:github.timeline] WHERE (type = 'WatchEvent' OR type = 'ForkEvent') AND repository_url = 'https://github.com/$repo'"  > data/csv/repositories/history_of_watchers/watchers_history_${fname}.csv
  fi
  counter=$((counter+1))
done;
