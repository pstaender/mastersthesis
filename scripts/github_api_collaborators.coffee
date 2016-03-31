#!/usr/bin/env coffee

fs = require('fs')
csv = require('csv')

Github = require('octonode')

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('repo', 'url of owner and repo')
  .example('repo', 'Microsoft/vscode')
  .describe('segment', 'segment of repo')
  .example('segment', 'collaborators to get `/repos/:owner/:repo/collaborators`')
  .default('segment', 'collaborators')
  .argv

client = Github.client(process.env.OAUTHTOKEN || "OAUTH_TOKEN")
# org = client.org("#{options.user}")
subsegment = 'collaborators'

allRepos = []
page = 1

client.limit (err, left, max) ->
  if err
    console.error """

    Use your GitHub access token to authenticate. Usage:
    $ export OAUTHTOKEN='yourgithubauthtoken'; coffee github_api_repository_subdata.coffee

    """
    throw err
  console.error """
  GitHub client limits
  #{left} / #{max} requests left
  """


# findRepos = (cb) ->
#
#   org.repos { per_page: 100, page: page }, (err, repos) ->
#     allRepos = allRepos.concat(repos) if repos
#     if repos.length is 100
#       page++
#       findRepos(cb)
#     else
#       cb(err, allRepos)
#     # console.log repos#, page
#
# findRepos ->
#   console.log JSON.stringify(allRepos, null, '  ')
