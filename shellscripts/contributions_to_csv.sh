#!/bin/bash

minContr=0
# top popular popular_exclusive rest
for section in popular rest; do
  #csvFile=../csv/contributions/contributions_repositories_$section.csv
  #echo "--> $csvFile"
  #cd ../scripts && coffee evaluate_contributions_ratio.coffee --minContributions=$minContr --repoQuery=$section > $csvFile
  # groupBy firm
  #csvFile=../csv/contributions/contributions_firms_$section.csv
  #echo "--> $csvFile (grouped by firms)"
  #cd ../scripts && coffee evaluate_contributions_ratio.coffee --minContributions=$minContr --repoQuery=$section --groupBy=firm > $csvFile
done;
