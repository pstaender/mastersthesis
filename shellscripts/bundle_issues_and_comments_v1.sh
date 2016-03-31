#!/bin/bash
trap "exit" INT
# data/apidata/repositories/*/*/issues_*.json
currentPWD=$(pwd)

cd scripts
# for issueFile in $currentPWD/data/apidata/repositories/facebook/bistro/issues_open*.json;
# for repo in $currentPWD/data/apidata/repositories/facebook/*;


for orgDir in $currentPWD/data/apidata/repositories/*;
do
  org=$(basename $orgDir)
  for repoDir in $orgDir/*;
  do
    repo=$(basename $repoDir)
    #
    # issues
    #
    cat $repoDir/issues_*.json | ./json_to_csv.coffee --flatten=true --fields="id,url,number,title,user.login,user.id,state,comments,created_at,updated_at,closed_at,body"  --apply="{
      body: (s) -> s?.trim()?.length or s
      url: (s) -> s?.replace(/^(https:\/\/api\.github\.com\/repos)\/(.+?)\/issues.*$/,'\$2')
    }" > $currentPWD/data/csv/repositories/issues/issues_${org}_${repo}.csv
    #
    # issue comment
    #
    cat $repoDir/comments/issue_comments_*.json | ./json_to_csv.coffee --flatten=true --fields="url,id,user.login,user.id,created_at,updated_at,body" --apply="{
      body: (s) -> s?.trim()?.length or s
      url: (s) -> s?.replace(/^(https:\/\/api\.github\.com\/repos)\/(.+?)\/issues.*$/,'\$2')
    }" > $currentPWD/data/csv/repositories/issues_comments/issues_comments_${org}_${repo}.csv
  done
done
