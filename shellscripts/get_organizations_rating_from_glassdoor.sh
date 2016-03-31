#!/bin/bash

# get license information and contributors

# GLASSDOOR_PARTNERKEY="…"
# GLASSDOOR_KEY="…"

targetFolder="../data/apidata/glassdoor/employers"
mkdir -p $targetFolder
trap "exit" INT

cd scripts

commercialOrgnaizations=$(cat ../data/csv/selected_commercial_organizations.csv | coffee filter_csv.coffee --fields="owner.login" --quote='')
#
counter=0


for org in $commercialOrgnaizations;
do
  echo $org
  #name=$(cat ../csv/organizations.csv | coffee filter_csv.coffee --fields="name" --where="login: '$org'" --terminator='')
  # echo $org
  # curl "http://api.glassdoor.com/api/api.htm?t.p=$GLASSDOOR_PARTNERKEY&t.k=$GLASSDOOR_KEY&useragent=&format=json&v=1&action=employers&q=$org" > $targetFolder/$org.json
done;
