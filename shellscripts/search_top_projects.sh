#!/bin/bash

# OAUTHTOKEN='…'
OUTPUTFOLDER=../data/apidata

mkdir -p $OUTPUTFOLDER

for PROGRAMMINGLANGUAGE in c%2B%2B c%23; do
  PAGE=1
  SORT=stars
  for PAGE in 1 2 3 4 5 6 7 8 9 10; do
    JSONFILE="$OUTPUTFOLDER/${PROGRAMMINGLANGUAGE}_${SORT}_${PAGE}.json"
    URL="https://api.github.com/search/repositories?q=language:$PROGRAMMINGLANGUAGE&sort=$SORT&order=desc&per_page=100&page=$PAGE"
    echo "curl -u username:$OAUTHTOKEN '$URL' > $JSONFILE"
  done;
done;
