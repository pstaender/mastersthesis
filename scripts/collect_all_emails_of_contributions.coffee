#!/usr/bin/env coffee

fs = require('fs')
path = require('path')
csv = require('csv')
glob = require('glob')
Sequence = require('sequence').Sequence
sequence = Sequence.create()

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('startAt', 'which position startAt')
  .default('startAt', '0')
  .describe('stopAt', 'which position stop')
  .default('stopAt', '10000')
  .describe('header', 'wride csv header')
  .default('header', 'true')
  .describe('csvFilePattern', 'which csv files to browse')
  .default('csvFilePattern', '../data/csv/repositories/logs/logs_*.csv')
  .argv

{ startAt, stopAt, header } = options
startAt = Number(startAt)
stopAt = Number(stopAt)

authors = {}
i = 0

console.log("\"email\",\"organizations\",\"names\"") if header is 'true'

stdoutData = ->
  for author of authors
    console.log "\"#{author}\",\"#{authors[author].orgs.join(';')}\",\"#{authors[author].names.join(';')}\""

glob options.csvFilePattern, {}, (err, files) ->
  files.forEach (file) ->

    organization = path.basename(file).replace(/^(.+?)_(.+?)_.+$/,'$2')
    i++

    if i < startAt
      return

    do (i, file) ->

      sequence.then (next) ->

        if i >= stopAt
          process.exit(0)
          return next()

        console.error "[#{i}]\t#{file}"

        csv.parse fs.readFileSync(file).toString(), { columns: true }, (err, rows) ->
          console.error(err, file) if err
          rows?.forEach (data) ->
            email = data?['author.email']?.trim() or null
            name = data?['author.name']?.trim() or null
            if name and email?.length > 0
              authors[email] ?= {
                names: []
                orgs: [ organization ]
              }
              authors[email].org ?= organization
              authors[email].names.push(name) if authors[email].names.indexOf(name) is -1
              authors[email].orgs.push(organization) if authors[email].orgs.indexOf(organization) is -1

          next()


        # if Number(data['frequency']) > 10
        #   console.log data['author.email'], data['frequency']



      # stream.pipe(csvStreamParser)

process.on 'exit', ->
  stdoutData()
#
#
#
#   console.error 'done'
