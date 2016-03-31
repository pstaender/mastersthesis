#!/usr/bin/env coffee

# export NODE_PATH=/usr/lib/node_modules (linux)
# export NODE_PATH=/usr/local/lib/node_modules/ (mac)

require('shelljs/global')
glob = require('glob')
fs = require('fs')
waitfor = require('waitfor')
ProgressBar = require('progress')
nodemailer = require('nodemailer')
transporter = nodemailer.createTransport('smtps://youremail%40gmail.com:passw@smtp.gmail.com')

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('startAt', 'startAt issue')
  .default('startAt', 1)
  .describe('stopAt', 'stopAt issue')
  .default('stopAt', 1000000)
  .argv

{ startAt, stopAt } = options
startAt = Number(startAt)
stopAt = Number(stopAt)
allIssuesCount = 0

mailAlreadySended = false

sendJobDoneEmail = (subject = "🐴 Job finished: #{startAt} - #{stopAt}", text = "Job finished: #{startAt} - #{stopAt}", html = 'Job finished: <b>#{startAt} - #{stopAt}</b>' ) ->
  return if mailAlreadySended
  mailOptions = {
    from: 'macminilocal <philipp@macmini.local>'        # sender address
    to: 'philipp.staender@gmail.com'                    # list of receivers
    subject
    text
    html
  }
  mailAlreadySended = true
  transporter.sendMail mailOptions, (error, info) ->
    console.error(error) if error
    console.log info
    exit(0)

process.on 'uncaughtException', ->
  sendJobDoneEmail()

glob "data/apidata/repositories/*/*/issues_*.json", {}, (err, files) ->
  total = 552703 # counted elsewhere
  # bar = new ProgressBar('repository [:bar] :percent :etas', { total: files.length })
  issueBar = new ProgressBar('processing issue [:bar] :percent :etas', { total })
  cd 'scripts'
  files.forEach (file, i) ->
    # console.log "[#{i}/#{files.length}]\t#{file}"

    content = fs.readFileSync('../'+file).toString()
    content = '{}' if content?.trim() is ''
    data = null
    try
      data = JSON.parse(content)
    catch e
      console.error content
      console.error "Error parsing JSON on file #{file}: #{e.message}"
      exit(1)
    # class script

    # exec "./github_api_repository_subdata_v3.coffee --url='"
    if data?.constructor is Array
      #allIssuesCount += data.length
      data.forEach (issue) ->
        allIssuesCount++
        echo "(#{allIssuesCount}/#{total})\t#{file} -> #{issue.comments_url}"
        return unless allIssuesCount >= startAt
        return if String(issue.comments).trim() is '0'
        # if allIssuesCount >= stopAt
        #   throw {}
        #   return
        exit(0) if allIssuesCount >= stopAt
        # https://api.github.com/repos/adafruit/Adafruit_9DOF/issues/2
        name = issue.url
        name = name.replace(/^.*github\.com\/repos\//i, '')
        name = name.replace(/\/issues\/.*$/i,'').replace(/\/+/g, '_')
        targetDir = '../'+file.replace(/\/issues_.+$/i, "/comments")
        mkdir '-p', targetDir
        target = targetDir + "/issue_comments_#{issue.number}_#{issue.id}_#{name}.json"
        commandStr = "./github_api_repository_subdata_v3.coffee --url='#{issue.comments_url}' > #{target}"
        console.error commandStr
        res = exec(commandStr)
        echo(res.stdout) if res.stdout?.trim()
        console.error(res.stderr) if res.stderr?.trim()
        issueBar.tick()
    # bar.tick()
    data = null

  console.log "#{allIssuesCount} issues count"
  sendJobDoneEmail()
