#!/bin/bash

fields='id,name,full_name,owner.login,owner.type,language,default_branch,created_at,updated_at,size,stargazers_count,open_issues_count,forks_count'
cd scripts
coffee transform_json_to_csv.coffee --fields="$fields" --header=only

for file in ../data/apidata/top_repos_by_language/*.json; do
  coffee transform_json_to_csv.coffee --fields="$fields" --file="$file" --jsonPath=items --header=false
done;
