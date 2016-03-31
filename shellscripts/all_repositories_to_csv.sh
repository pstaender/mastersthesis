#!/bin/bash
fields='id,name,full_name,owner.login,size,language,stargazers_count,forks_count,subscribers_count,open_issues_count,fork,language,default_branch,is_top_project'
cd scripts
coffee transform_json_to_csv.coffee --fields="$fields" --header=only
trap "exit" INT
for file in ../data/apidata/repositories/*/repositories_*.json;
  do
    coffee transform_json_to_csv.coffee --file="$file" --fields="$fields"
  done;
