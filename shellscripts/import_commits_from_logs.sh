#!/bin/bash
FILES=/Users/philipp/repositories/logs/*
for f in $FILES
do
  >&2 echo "processing logfile $f"

  # import to mongodb
  # cd ~/masterthesis/scripts && coffee import_git_projects_to_db.coffee $f

  # to csv
  #cd ~/masterthesis/scripts && coffee import_git_projects_to_csv.coffee --emailPattern '@(.+\\.)*github\\.com\\s*$' $f
  # >  $f.csv
done


cd ~/masterthesis/scripts && coffee import_git_projects_to_csv.coffee --emailPattern '@(.+\.)*github\.com\s*$' /Users/philipp/repositories/logs/atom.log > ~/atom_contributions.csv

cd ~/masterthesis/scripts && coffee import_git_projects_to_csv.coffee --emailPattern '@(.+\.)*microsoft\..+\s*$' /Users/philipp/repositories/logs/vscode.log > ~/vscode_contributions.csv
