#!/usr/bin/env coffee
json2csv = require('json2csv')
JSONStream = require('JSONStream')
_ = require('lodash')
# { camelize, underscored } = require('underscore.string')
fs = require('fs')

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('header', 'display csv header [true,false,only]')
  .default('header', 'true')
  .describe('fields', 'comma sperated fields (e.g. `id,name,owner.login`)')
  .describe('file', 'path to json file')
  .describe('delimiter', 'csv delimiter')
  .default('delimiter', ',')
  .demand(['fields'])
  .describe('jsonPath', 'path of parsing (e.g. `items`)')
  .argv

jsonFile = options.file
delimiter = options.delimiter

# parser = JSONStream.parse(options.jsonPath)

#'id,name,fullName,ownerLogin,ownerType,language,defaultBranch,createdAt,updatedAt,size,stargazersCount,openIssuesCount,forksCount'
fields = options.fields.split(delimiter)

if options.header is 'only'
  console.log('"'+fields.join('"'+delimiter+'"')+'"')
  process.exit(0)

data = JSON.parse(fs.readFileSync(jsonFile).toString())
if options.jsonPath
  data = _.get(data, options.jsonPath)

hasCSVColumnTitle = if options.header is 'false' or not options.header then false else true

console.log hasCSVColumnTitle

json2csv { data, fields, hasCSVColumnTitle }, (err, csv) ->
  if err
    console.error 'json2csv error:', err
    process.exit(1)
  else
    console.log(csv)
    console.error "Done with file '#{jsonFile}'"
    process.exit(0)


# fs.createReadStream(jsonFile).pipe parser
#
# result = []
#
# parser.on 'data', (data) ->
#   result.push(data)
