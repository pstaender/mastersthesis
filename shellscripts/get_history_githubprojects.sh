#!/bin/bash
trap "exit" INT
# 01 10 20 X
# 05 15 25 X
# 03 08 13 18 23 28 X
# 04 07 14 17 24 27 X
# 06 09 12 16 19 21 X
# 02 11 22 26 27 29 30 31 X

# the folder where to store all downloaded json files temporarily

tempJSONDirectory="../temp/githubarchive"

mkdir -p $tempJSONDirectory

cd $tempJSONDirectory

for year in 2015 2014 2013 2012 2011; do
  for month in 01 02 03 04 05 06 07 08 09 10 11 12; do
    for hour in 1 2 3 4 5 6 7 8 9 10 12 13 14 15 16 17 18 19 20 21 22 23; do
      for day in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31; do
        file="$year-$month-$day-$hour.json.gz"
        url="http://data.githubarchive.org/$file"
        # the (optional) argument `check` can be used to confirm that the requested file is already downloaded
        if [ "$1" == 'check' ]; then
          if [ ! -f $file ]; then
            if [ "$2" == 'get' ]; then
              echo "--> downloading $url"
              wget $url
            else
              echo $file
            fi
          fi
        else
          echo "--> downloading $url"
          wget $url
        fi
      done;
    done;
  done;
done;
