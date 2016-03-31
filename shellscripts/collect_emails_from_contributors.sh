#!/bin/bash
orgs=$(cd scripts && coffee filter_csv.coffee --file=../data/csv/commercial_classification/commercial_classification_of_organizations.csv --fields="login" --where="is_commercial: 'yes'" --quote='')

# repos=`cd ../scripts && coffee `

trap "exit" INT

cd scripts

orgs="google openstack"

for org in $orgs; do
  coffee collect_all_emails_of_contributions.coffee --header=true --csvFilePattern="../data/csv/repositories/logs/logs_${org}_*.csv" --startAt=0 --stopAt=299 > ../data/csv/repositories/contributors/contributors_$org.csv

  coffee collect_all_emails_of_contributions.coffee --header=true --csvFilePattern="../data/csv/repositories/logs/logs_${org}_*.csv" --startAt=300 --stopAt=600 >> ../data/csv/repositories/contributors/contributors_$org.csv
done;
