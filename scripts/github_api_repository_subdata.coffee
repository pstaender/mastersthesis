console.error('Deprecated because bugs are known. Use github_api_repository_subdata_v2.coffee instead.')
console.log('exiting now')
return process.exit(1)

fs = require('fs')
csv = require('csv')
CSON = require('cson-parser')
Github = require('octonode')

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('urlSegment', 'main url segment')
  .example('urlSegment', 'Microsoft/vscode')
  .describe('perPage', 'how many items per page')
  .default('perPage', 100)
  .describe('page', 'which page to request, 0 for merging all pages')
  .default('page', 0)
  .describe('segment', 'segment of repo')
  .describe('endpoint', 'api endpoint')
  .describe('parameters', 'key/values query parameters for api request')
  .default('parameters', '')
  .example('parameters', 'filter: "all", direction: "desc"')
  .describe('header', 'optional comma sperated values for header')
  .example('header', 'Accept: "application/vnd.github.drax-preview+json"')
  .describe('url', 'give a full url')
  .default('endpoint', 'issues')
  .example('subsegment', 'contributors to get `/repos/:owner/:repo/contributors`')
  .default('subsegment', '')
  # .demand(['urlSegment'])
  .argv

client = Github.client(process.env.OAUTHTOKEN || "OAUTH_TOKEN")
# org = client.org("#{options.user}")
{ subsegment, parameters } = options

# /repos/:owner/:repo
parameters = CSON.parse(parameters) if parameters

if options.header
  client.requestOptions
    headers:
      CSON.parse(options.header)

url = options.url or "/#{options.endpoint}/#{options.urlSegment}/#{options.subsegment}"

per_page = Number(options.perPage)
page = if Number(options.page) > 0 then Number(options.page) else undefined

_dataEchoedAlready = false

stdout = (d, closing = false) ->
  if d?.constructor is Array
    console.log '[' if _dataEchoedAlready is false
    d.forEach (item, i) ->
      prefix = if _dataEchoedAlready is true and i < d.length then ', ' else ''
      console.log prefix + JSON.stringify(item, null, '  ')
      _dataEchoedAlready = true
    console.log ']' if closing
  else
    console.log JSON.stringify(d, null, 2)

client.limit (err, left, max) ->
  if err
    console.error """

    Use your GitHub access token to authenticate. Usage:
    $ export OAUTHTOKEN='yourgithubauthtoken'
    $ coffee github_api_repository_subdata.coffee

    """
    throw err
    process.exit(1)
  console.error """
  GitHub client limits: #{(max-left)} / #{max} -> #{left} requests left
  """

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
          process.exit(0)
        else if body.length is per_page
          stdout(body)
          currentPage++
          getData(currentPage)
        else
          stdout(body, true)
          process.exit(0)


  getData(page)
