#!/usr/bin/env coffee

fs = require('fs')
csv = require('csv')

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('user', 'user')
  .describe('csvFileAll', 'csv file of all repos')
  .default('csvFileAll', '../data/csv/all_organizations_repositories.csv')
  .describe('csvFileNew', 'csv file of additional repo data')
  .default('csvFileNew', '../data/csv/top_repositories.csv')
  .argv

csvFileAll = fs.readFileSync(options.csvFileAll)
throw Error("CSV file '#{csvFileAll}' for all repos doesnt exists") unless csvFileAll
csvFileNew = fs.readFileSync(options.csvFileNew)
throw Error("CSV file '#{csvFileNew}' for additional repos doesnt exists") unless csvFileNew

key = 'is_top_project'
defaultValues = 'T,F'.split(',')
idKey = 'id'

csv.parse csvFileAll.toString(), { columns: true }, (err, allRepos) ->
  throw err if err
  csv.parse csvFileNew.toString(), { columns: true }, (err, additionalRepos) ->
    throw err if err
    additionalReposIndex = {}
    # echo header
    console.log '"'+Object.keys(allRepos[0]).join('","')+'"'

    additionalRepos.forEach (additionalRepo) ->
      additionalReposIndex[additionalRepo[idKey]] = true

    allRepos.forEach (repo) ->
      repo[key] = if Boolean(additionalReposIndex[repo[idKey]] is true) then defaultValues[0] else defaultValues[1]
      values = for attr of repo
        repo[attr]
      console.log '"'+values.join('","')+'"'

    # console.log additionalReposIndex
