#!/usr/bin/env coffee

fs = require('fs')
csv = require('csv')
GitHubApi = require("github")

Github = require('octonode')

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('user', 'user')
  .describe('csvFile', 'csv file')
  .describe('includeRepository', 'downlaoad repository data')
  .default('includeRepository', true)
  .describe('includeCollaborators', 'downlaoad colloborator data')
  .default('includeCollaborators', true)
  .describe('includeIssues', 'downlaoad issues data')
  .default('includeIssues', false)
  .describe('includeIssueComments', 'downlaoad issue comments')
  .default('includeIssueComments', false)
  .argv


jsonFile = options.csvFile or false

if jsonFile and not fs.existsSync(jsonFile)
  console.error "error: file '#{jsonFile}' doesnt exists"
  process.exit(1)

if jsonFile
  csv.parse fs.readFileSync(jsonFile).toString(), { columns: true },(err, data) ->
    rows = for row in data
      row.ownerLogin
    # this script is to recursively call itself ;)
    # rows = [ rows[0] ]

    console.log """
    #!/bin/sh

    for org in #{rows.join(' ')};
      do
        mkdir -p ../apidata/repositories/\${org}
        coffee github_api_repositories.coffee --user=\$org > ../apidata/repositories/repositories_\${org}/.json
      done;
    """
else if options.user
  console.error "--> #{options.user}"

  github = Github.client(process.env.OAUTHTOKEN || "OAUTH_TOKEN")
  org = github.org("#{options.user}")

  allRepos = []
  page = 1

  findRepos = (cb) ->

    org.repos { per_page: 100, page: page }, (err, repos) ->
      allRepos = allRepos.concat(repos) if repos
      if repos.length is 100
        page++
        findRepos(cb)
      else
        cb(err, allRepos)
      # console.log repos#, page

  findRepos ->
    console.log JSON.stringify(allRepos, null, '  ')
