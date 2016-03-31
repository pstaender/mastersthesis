#!/bin/bash
trap "exit" INT
# data/apidata/repositories/*/*/issues_*.json
currentPWD=$(pwd)

cd scripts
# for issueFile in $currentPWD/data/apidata/repositories/facebook/bistro/issues_open*.json;
# for repo in $currentPWD/data/apidata/repositories/facebook/*;


#$currentPWD/data/apidata/repositories/*;
for orgDir in $currentPWD/data/apidata/repositories/owncloud $currentPWD/data/apidata/repositories/paypal $currentPWD/data/apidata/repositories/phacility $currentPWD/data/apidata/repositories/sourcegraph $currentPWD/data/apidata/repositories/spotify $currentPWD/data/apidata/repositories/square $currentPWD/data/apidata/repositories/stripe $currentPWD/data/apidata/repositories/thoughtbot $currentPWD/data/apidata/repositories/tumblr $currentPWD/data/apidata/repositories/twilio $currentPWD/data/apidata/repositories/twitter $currentPWD/data/apidata/repositories/venmo $currentPWD/data/apidata/repositories/xamarin $currentPWD/data/apidata/repositories/yahoo $currentPWD/data/apidata/repositories/yhat;
do
  org=$(basename $orgDir)
  echo "--> $org"
  csvFile="$currentPWD/data/csv/repositories/issues/issues_${org}.csv"
  echo '"id","url","number","title","user.login","user.id","state","comments","created_at","updated_at","closed_at","body"
' > $csvFile
  for file in $orgDir/*/issues_*.json;
  do
    echo "+++ $(dirname $file)/issues"
    cat $file | ./json_to_csv.coffee --flatten=true --header="false" --fields="id,url,number,title,user.login,user.id,state,comments,created_at,updated_at,closed_at,body"  --apply="{
      body: (s) -> s?.trim()?.length or s
      url: (s) -> s?.replace(/^(http[s]*:\/\/api\.github\.com\/repos)\/(.+?)\/issues.*$/,'\$2')
    }" >> $csvFile
  done;
  #
  # issue comment
  #
  csvFile="$currentPWD/data/csv/repositories/issues_comments/issues_comments_${org}.csv"
  echo '"url","issue_url","id","user.login","user.id","created_at","updated_at","body"' > $csvFile
  for file in $orgDir/*/comments/issue_comments_*.json;
  do
    echo "+++ $(basename $file)"
    cat $file | ./json_to_csv.coffee --header="false" --flatten=true --fields="url,issue_url,id,user.login,user.id,created_at,updated_at,body" --apply="{
      body: (s) -> s?.trim()?.length or s
      url: (s) -> s?.replace(/^(http[s]*:\/\/api\.github\.com\/repos)\/(.+?)\/issues.*$/,'\$2')
      issue_url: (s) -> s?.replace(/^(.+?)\/([0-9]+)$/,'\$2')
    }" >> $csvFile
  done
done
