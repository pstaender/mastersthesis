#!/usr/bin/env coffee

json2csv = require('json2csv')
JSONStream = require('JSONStream')
expandHomeDir = require('expand-home-dir')
coffee = require('coffee-script')
_ = require('lodash')
# { camelize, underscored } = require('underscore.string')
fs = require('fs')

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('header', 'display csv header [true,false,only]')
  .default('header', 'true')
  .describe('fields', 'comma sperated fields (e.g. `id,name,owner.login` or `*` for all)')
  .default('fields', '*')
  .describe('file', 'path to json file')
  .default('file', '')
  .describe('flatten', 'flatten JSON, so user.login.name is possible as column')
  .default('flatten', 'false')
  .describe('delimiter', 'csv delimiter')
  .default('delimiter', ',')
  .describe('quote', 'csv quote')
  .default('quote', '"')
  .describe('apply', 'Apply coffeescript function on field')
  .example('apply', 'body: (s) -> s?.trim().length')
  .alias('quote', 'terminator')
  # .demand(['fields'])
  .describe('jsonPath', 'path of parsing (e.g. `items`)')
  .epilogue("""
    converts json data to csv
    Data can be given by a file or pipe
      1) cat data.json | coffee json_to_csv.coffee > data.csv
         or
      2) coffee json_to_csv.coffee --file=data.json > data.csv
  """)
  .argv

{ delimiter, fields, file, quote, jsonPath, header, flatten, apply } = options

if apply
  # yep, it's dangerous - but too practical in this case
  applyRules = coffee.eval(apply.trim())
else
  applyRules = false

flatten = if flatten is 'false' then false else true

# fields = if fields is '*' then [] else options.fields.split(delimiter)

if file.trim()
  file = expandHomeDir(file)
  if not fs.lstatSync(file)
    console.error("File '#{file}' doesnt exists / isnt readable")
    process.exit(1)
  else
    stream = fs.createReadStream(file)
else
  # stream via stdin
  stream = process.stdin

parser = if jsonPath then JSONStream.parse(jsonPath.split(',')) else JSONStream.parse()

headerIsProcessed = if header is 'false' then true else false

processHeader = (data, header, json2csvOptions) ->
  if header is 'only'
    json2csvOptions.data = data[0] # we only need the first row, maybe faster?!
  else
    json2csvOptions.data = data
  json2csvOptions.hasCSVColumnTitle = true

  if fields isnt '*' and fields.trim().length > 0
    # specific fields
    json2csvOptions.fields = fields.split(delimiter)

  json2csv json2csvOptions, (err, csv) ->
    if header is 'only'
      console.log(csv.split('\n')[0])
      process.exit(0)
    else
      console.log(csv)


parser
  .on 'data', (data) ->
    # check if data is array, if not -> transform to array of length 1
    if data? and data.constructor isnt Array
      data = [data]

    if typeof applyRules is 'object' and data?.length > 0
      data.forEach (r, i) ->
        for attr of applyRules
          if typeof data[i][attr] isnt 'undefined'
            if typeof applyRules[attr] is 'function'
              data[i][attr] = applyRules[attr](data[i][attr])
            else
              data[i][attr] = applyRules[attr]

    json2csvOptions = {flatten}

    json2csvOptions.fields = fields.split(delimiter) if fields isnt '*'

    unless headerIsProcessed
      headerIsProcessed = true
      processHeader(data, header, json2csvOptions)
    else
      # print out rows
      json2csvOptions.data = data
      json2csvOptions.hasCSVColumnTitle = false
      json2csv json2csvOptions, (err, csv) ->
        console.log csv

stream
  .pipe(parser)
