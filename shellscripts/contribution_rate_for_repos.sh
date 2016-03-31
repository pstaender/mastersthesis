#!/bin/bash

trap "exit" INT

for file in data/csv/repositories/logs/logs_*.csv;
  do
    # echo $file
    cat $file
    #coffee transform_json_to_csv.coffee --file="$file" --fields="$fields" --header=false
  done;
