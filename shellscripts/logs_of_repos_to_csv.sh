#!/bin/bash

trap "exit" INT

startDir=$(pwd)
data=$(cd scripts && coffee filter_csv.coffee --file=../data/csv/all_organizations_repositories.csv --fields="full_name,default_branch,fork" --where="fork: 'false'" --seperator="," --stringDelimiter="")

counter=0

csvTargetDir="$startDir/data/csv/repositories/logs"
mkdir -p $csvTargetDir

min=${1:-0}
max=${2:-100000}

for line in $data; do
  parts=(${line//,/ })
  branch=${parts[1]}
  repo=${parts[0]}
  if [ "$counter" -ge $min ] && [ "$counter" -le $max ]; then
    dateTime=$(date +"%m-%d-%y %T")
    echo "[$counter] $dateTime $repo cloning ..." | tee /dev/stderr
    fname=$(echo $repo | sed "s/\\//_/")
    target="$HOME/temp/github_repositories/$repo"
    mkdir -p $target
    cd $target
    git clone --quiet https://github.com/$repo.git .
    echo "checkout to branch $branch"
    #git --git-dir="$target/.git" stash
    git checkout $branch
    echo "writing git log to $csvTargetDir/logs_$fname.csv"
    cd $startDir/scripts
    git --git-dir="$target/.git" log | coffee git_log_to_csv.coffee > $csvTargetDir/logs_$fname.csv
    rm -rf $target
  fi
  counter=$((counter+1))
done;
