#!/usr/bin/env coffee

fs   = require('fs')
moment = require('moment')
split = require('split')
csv = require('csv')

args = require('yargs')
  .locale('en_US')
  # .usage('Usage: $0 $commits.log')
  .describe('dateFormat', 'date format')
  .default('dateFormat', 'YYYY-MM-D H:mm:ss ZZ')
  .help('h')
  .alias('h', 'help')
  .epilogue("""
    git logs to csv
    Expected git log in stdin, i.e. `git log | coffee git_log_to_csv.coffee`
  """)
  .argv

dateFormat = args.dateFormat

commitToObject = (commit) ->

  ###
  commit a35c785202ef7351f1e071a0191b201b745da168
  Merge: fbb9327 12667fc
  Author: Jake Wharton <JakeWharton@GMail.com>
  Date:   Sun Jul 26 21:10:39 2015 -0400

      Merge pull request #1090 from jobi/stop-placeholder-on-error

      Stop placeholder animation on errors
  ###

  s = '\n'+commit.replace(/^commit\s/,'')
  commit = s.match(/\n([a-f0-9]{40})\n/)?[1]?.trim() or null
  return null if not commit
  authorMatch = s.match(/\nAuthor\:\s+(.+?)\<(.*?)\>/)
  # if not authorMatch
    # console.error s, authorMatch
  author =
    name: authorMatch[1].trim()
    email: authorMatch[2]?.trim() or null
  date_string = s.match(/\nDate\:\s+(.+?)\n/i)?[1]?.trim() or null
  date = new Date(date_string)
  merges = s.match(/\nMerge:\s+(.+?)\n/i)?[1] or []
  s = s.trim()
  message = s.match(/\n\n(.*)/)?[1]?.trim()
  if merges.length > 0
    merges = merges.split(' ')
  { author, commit, merges, date, date_string, message }

fields = 'commit,author.name,author.email,date,date_string,merges_count'.split(',')
console.log '"'+fields.join('","')+'"'

process.stdin
  .pipe(split(/\ncommit\s/))
  .on 'data', (commitString) ->
    commit = commitToObject(commitString)
    if commit
      console.log '"'+[
        commit.commit
        commit.author?.name or ''
        commit.author?.email or ''
        commit.date
        commit.date_string
        commit.merges?.length
      ].join('","')+'"'
  .on 'end', ->
    process.exit(0)
