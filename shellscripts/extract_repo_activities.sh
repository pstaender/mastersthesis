#!/bin/bash
# Usage ./shellscripts/extract_repo_activities.sh > repo_activities_2011-2015.csv
trap "exit" INT
scriptPath="$(pwd)/scripts"
# all commercial organizations / firms
orgs="adafruit|airbnb|alibaba|apple|applidium|Automattic|aws|Azure|bitly|cesanta|chef|cloudera|collectiveidea|cucumber|docker|douban|dropbox|elastic|enormego|etsy|facebook|Flipboard|getsentry|github|gliderlabs|google|googlesamples|hashicorp|heroku|id-Software|Instagram|intridea|KnpLabs|linkedin|mapbox|Microsoft|mongodb|mutualmobile|Netflix|openstack|owncloud|ParsePlatform|paypal|phacility|plataformatec|Qihoo360|Reactive-Extensions|ServiceStack|Shopify|sourcegraph|spotify|square|stripe|thoughtbot|tumblr|twilio|twitter|ValveSoftware|venmo|xamarin|yahoo|Yalantis|Yelp|yhat"
# path to output file
outputCSV=../temp/filtered_repo_activities

# put in the folder where all the thousand downloaded json files are
for file in /media/temp/githubarchive/*.json.gz; do
  echo "processing $file"
  for eventType in ForkEvent WatchEvent; do
    gunzip -c $file | grep "\"$eventType\"" | egrep "\"($orgs)/" >> $outputCSV.$eventType.json
  done;
done;
