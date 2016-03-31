#!/usr/bin/env coffee

fs = require('fs')
csv = require('csv')
CSON = require('cson-parser')
Github = require('octonode')
moment = require('moment-timezone')

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('perPage', 'how many items per page')
  .default('perPage', 100)
  .describe('page', 'which page to request, 0 for merging all pages')
  .default('page', 0)
  .describe('parameters', 'key/values query parameters for api request')
  .default('parameters', '')
  .example('parameters', 'filter: "all", direction: "desc"')
  .describe('header', 'optional comma sperated values for header')
  .example('header', 'Accept: "application/vnd.github.drax-preview+json"')
  # .describe('url', 'give a full url')
  # .default('endpoint', 'issues')
  # .example('subsegment', 'contributors to get `/repos/:owner/:repo/contributors`')
  # .default('subsegment', '')
  # .epilog("""URL schema:
  # `repos/organizationname/reponame/issues/1/comment` would be set as:
  # `{endpoint}/{urlSegment}/{subsegment}`
  # Numbers will be set between {urlSegment}/{i}/{subsegment}
  # """)
  .demand(['url'])
  .argv

client = Github.client(process.env.OAUTHTOKEN || "OAUTH_TOKEN")
# console.error(process.env.OAUTHTOKEN)
# org = client.org("#{options.user}")
{ url, parameters } = options

# /repos/:owner/:repo
parameters = CSON.parse(parameters) if parameters

if options.header
  client.requestOptions
    headers:
      CSON.parse(options.header)

url = options.url

per_page = Number(options.perPage)
page = if Number(options.page) > 0 then Number(options.page) else undefined

_dataEchoedAlready = false

itemsAreUsed = false

stdout = (d, closing = false) ->
  if d?.constructor is Array
    itemsAreUsed = true if itemsAreUsed is false
    console.log '[' if _dataEchoedAlready is false
    d.forEach (item, i) ->
      prefix = if _dataEchoedAlready is true and i < d.length then ', ' else ''
      console.log prefix + JSON.stringify(item, null, '  ')
      _dataEchoedAlready = true
    console.log ']' if closing
  else
    console.log JSON.stringify(d, null, 2)

client.limit (err, left, max, body) ->
  resetAt = ''
  if body?.rate?.reset
    resetAt = moment.tz(Number(body.rate.reset)*1000, "America/Los_Angeles").tz("Europe/Berlin").format('DD.MM HH:mm')
    resetAt = "(Next reset at: #{resetAt})"
  console.error """
  GitHub client limits: #{(max-left)} / #{max} -> #{left} requests left #{resetAt}
  """

  if err
    console.error """

    Use your GitHub access token to authenticate. Usage:
    $ export OAUTHTOKEN='yourgithubauthtoken'
    $ coffee github_api_repository_subdata.coffee

    """
    throw err
    process.exit(1)

  options = {
    per_page: per_page
  }

  if parameters
    for attr of parameters
      options[attr] = parameters[attr]

  getData = (currentPage = 1) ->
    options.page = currentPage
    console.error "-->  #{url}  ##{currentPage}"
    client.get url, options, (err, status, body, headers) ->
      if err
        console.error(err)
        console.error('exiting now')
        process.exit(1)
      else
        if body.length is 0
          console.log(']') if itemsAreUsed
          process.exit(0)
        else if body.length > 0
          stdout(body)
          currentPage++
          getData(currentPage)
        else
          stdout(body, true)
          process.exit(0)


  getData(page)
