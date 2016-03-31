#!/bin/bash

header='"email","organizations","names"'

trap "exit" INT

echo $header

# scriptPath="$(pwd)/scripts"

for file in $(pwd)/data/csv/repositories/contributors/*.csv; do
  cat $file | sed 's/"email","organizations","names"//' | grep -v '^$'
done;
