#!/bin/bash
trap "exit" INT
cd scripts
#2012 2013 2014 2015
for year in 2011;
do
  for file in /Volumes/Backup/githubarchive/${year}-*.json.gz;
  do
    echo "== Processing $file"
    zcat $file | ./events_of_repositories_to_csv_files.coffee --doCount=false --dry-run=false
  done
done
