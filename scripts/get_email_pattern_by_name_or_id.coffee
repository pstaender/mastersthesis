#!/usr/bin/env coffee

fs = require('fs')
expandHomeDir = require('expand-home-dir')
_ = require('lodash')
csv = require('csv')

# organizations = JSON.parse(fs.readFileSync('../apidata/organizations_top_repos_restructured.json').toString())
# console.log organizations[0]
# process.exit(0)

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('file', 'csv file')
  .default('file', '../csv/top_repositories.csv')#'../csv/commercial_classification/commercial_classification_of_organizations.csv')
  .describe('where', 'id or login_name')
  .default('where', '')
  .describe('delimiter', 'column delimiter')
  .default('delimiter', ',')
  .describe('quote', 'string quote')
  .default('quote', '"')
  .argv

{ where, file, delimiter, quote } = options

file = expandHomeDir(file)
if not fs.lstatSync(file)
  console.error("File '#{file}' doesnt exists / isnt readable")
  process.exit(1)

stream = fs.createReadStream(file)

console.log "#{quote}id#{quote}#{delimiter}#{quote}owner.login#{quote}"

orgs = {}

csvStreamParser = csv.parse({ columns: true })
csvStreamParser.on 'data', (data) ->
  # data.forEach (row) ->
  if data?['owner.type'] is 'Organization'
    orgs[data['owner.login']] = true
    # console.log data
  # if where
  #   unless isNaN(where)
  #     data = _.find([data], { id: where })
  #   else
  #     data = _.find([data], { 'owner.login': where })
  #
  #   if data
  #     console.log data
csvStreamParser.on 'end', ->
  console.log Object.keys(orgs).join(' ')

stream.pipe(csvStreamParser)
