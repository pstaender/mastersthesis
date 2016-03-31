#!/usr/bin/env coffee

fs = require('fs')
expandHomeDir = require('expand-home-dir')
csv = require('csv')
_ = require('lodash')
CSON = require 'cson-parser'

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('file', 'csv file')
  .describe('where', 'json or cson object as where condition')
  .example('where', '\'key: "thisvalue"\'')
  .default('where', '')
  .describe('fields', 'fields to display')
  .default('fields', '*')
  # .describe('seperator', 'column delimiter')
  # .default('seperator', ',')
  # .describe('stringDelimiter', 'column delimiter')
  # .default('stringDelimiter', '"')
  .describe('delimiter', 'column delimiter')
  .default('delimiter', ',')
  .describe('quote', 'string quote')
  .default('quote', '"')
  .alias('quote', 'stringDelimiter')
  .alias('quote', 'terminator')
  .alias('delimiter', 'seperator')
  .argv

{ where, delimiter, quote } = options



if options.file?.trim()
  options.file = expandHomeDir(options.file)
  if not fs.lstatSync(options.file)
    console.error("File '#{options.file}' doesnt exists / isnt readable")
    process.exit(1)
  else
    stream = fs.createReadStream(options.file)
else
  # stream via stdin
  stream = process.stdin

where = CSON.parse(where) if where?.trim().length > 0

csvStreamParser = csv.parse({ columns: true })
csvStreamParser.on 'data', (data) ->
  if where
    data = _.find([data], where)
  if typeof data is 'object'
    if options.fields is '*'
      values = for attr of data
        data[attr]
    else
      values = for attr in options.fields.split(',')
        data[attr]
    # if options.fields.split(',')?.length is 1
    #   console.log values[0]
    # else
    #   true
    console.log quote+values.join(quote+delimiter+quote)+quote

stream.pipe(csvStreamParser)
