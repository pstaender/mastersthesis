#!/usr/bin/env coffee

require('shelljs/global')
fs = require('fs')

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('dryRun', 'write csv files, set to fals if you want to write csv files')
  .default('dryRun', 'true')
  .describe('csvFile', 'csv file of events')
  .describe('event', 'ForkEvent or WatchEvent')
  .default('event', '(ForkEvent|WatchEvent)')
  .describe('doCount', 'Counter (for orientation)')
  .default('doCount', 'true')
  .demand(['event'])
  .argv

pwd = exec("pwd", { silent: true }).stdout.trim()

repos=exec("../scripts/filter_csv.coffee --file='../data/csv/repositories_details.csv' --where=\"is_by_commercial_organization: 'true'\" --fields=\"organization_name,repository_name,id\"", { silent: true })

allRepos = {}
allReposByURL = {}

repos.stdout.split("\n").forEach (line) ->
  return unless line?.trim()
  parts = line.replace(/\"/g,'').split(",")
  org = parts[0]
  repo = parts[1]
  id = String(parts[2])
  allRepos[id] = { org, repo, id }
  url = "#{org}/#{repo}"
  allReposByURL[url] = allRepos[id]

# console.log repos, allReposByURL, allRepos


JSONStream = require('JSONStream')
parser = JSONStream.parse()

# parser = require('clarinet').createStream()

CSON = require 'cson-parser'

{ csvFile, event, dryRun, doCount } = options

doCount = if doCount is 'true' then true else false

dryRun = if dryRun is 'false' then false else true

# tail -c +1048576 # by byte
# tail --lines=+
# tail -n +700

stream = if csvFile then fs.createReadStream(csvFile) else process.stdin

# where = CSON.parse(where)



fields = 'repo_id,repo_url,type,created_at,actor_id,actor_url,actor_login,id,event_type'.split(',')

headerString = '"'+fields.join('","')+'"'

class Repo
  repo_id: -1
  repo_url: ''
  type: ''
  created_at: ''
  actor_id: -1
  actor_login: ''
  id: -1
  event_type: event

i=0
j=0

_data = ''

parser
.on 'data', (data) ->
  j++
  # return unless j > 30612
  console.log "((#{j}))" if doCount
  _data = data
  #if data?.type?.toLowerCase() is event.toLowerCase()
  if data?.type? and new RegExp(event, 'i').test(data.type)
    # if data.repo?.id
    #   dataRepo = data.repo
    # else if data.repository
    #   dataRepo = data.repository
    if data.repo?.id and Number(data.repo?.id) >= 0
      dataRepo = data.repo
    else if typeof data.repository is 'object'
      dataRepo = data.repository
    else if typeof data.repo is 'object'
      dataRepo = data.repo
    else
      console.log "No repository data found"

    # console.log dataRepo.name, dataRepo.id, data
    # exit(0)

    return unless dataRepo

    i++

    # get repo is or urls
    url = null
    if dataRepo.id
      # console.log "FOUND id: #{dataRepo.id}"
      url = Number(dataRepo.id)
    else if dataRepo.full_name
      url = dataRepo.full_name
      # console.log "FOUND full_name: #{dataRepo.full_name}"
      # console.log dataRepo
    else if dataRepo.name
      # console.log "FOUND name: #{dataRepo.name}"
      if dataRepo.url
        url = dataRepo.url.replace(/^http(s)*:\/\/(api\.|www)*github\.(com|dev)\//i, '')
      # console.log dataRepo, url
    # console.error data.repo or data.repository, url
    # console.log "#{j}\t#{url}"
    # return
    unless url
      console.error "Couldnt detect id/url"
      return
    foundRepo = if url >= 0 and typeof allRepos[url] is 'object' then allRepos[url] else allReposByURL[url]

    if typeof foundRepo isnt 'object'
      # console.error "Repo not found in list: #{url}"
    else
      id = foundRepo.id

      r = new Repo()
      r.repo_id = id
      r.repo_url = dataRepo.full_name or dataRepo.name
      # console.log dataRepo, r
      # exit(0)
      console.error "+++ #{r.repo_url} (#{id}|#{data.id or -1}) [#{i}]"

      r.type = data.type
      r.created_at = data.created_at
      dataActor = data.actor_attributes or data.actor
      # if typeof dataActor is 'string'
      #   r.actor_login = dataActor.actor_login
      # old event data format
      if data.actor_attributes
        r.actor_id = data.actor_attributes.id or -1
        r.actor_url = data.actor_attributes.url or ''
        r.actor_login = data.actor_attributes.login
      else
        r.actor_id = dataActor?.id
        r.actor_url = data.actor?.url
        r.actor_login = data.actor?.login
      r.id = data.id or -1
      eventType = data.type
      r.event_type = eventType
      d = fields.map (field) ->
        r[field] or ''

      line = '"'+d.join('","')+'"'


      outputFile = "#{pwd}/../data/csv/repositories/#{eventType.toLowerCase()}/#{eventType.toLowerCase()}_#{foundRepo.org}_#{foundRepo.repo}.csv"
      console.error "--> #{outputFile}#{if dryRun then ' [dryRun]' else ''}"
      try
        fs.statSync(outputFile) unless dryRun
      catch e
        fs.writeFileSync(outputFile, headerString) unless dryRun
      if dryRun
        console.log line
      else
        fs.appendFileSync(outputFile, "\n"+line)

  else if not data?.type
    console.error 'Unknown type: ', data?.type


# parser
# .on 'error', (err) ->
#   console.error err, JSON.stringify(_data)
#   process.exit(1)

stream.pipe(parser)
