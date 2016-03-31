fs = require('fs')
path = require('path')
csv = require('csv')
glob = require('glob')
ProgressBar = require('progress')
Sequence = require('sequence').Sequence
sequence = Sequence.create()
_ = require('lodash')

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
  .default('csvFilePattern', '../data/csv/repositories/contributors/contributors_{organization}.csv')
  .describe('outputFileContributersByEmail', 'outputFile #1')
  .default('outputFileContributersByEmail', '../data/json/contributors_by_email.json')
  .describe('outputFileContributersByName', 'outputFile #2')
  .default('outputFileContributersByName', '../data/json/contributors_by_name.json')
  .describe('csvFileCommercialOrganizations', 'which organizations')
  .default('csvFileCommercialOrganizations', '../data/csv/commercial_classification/commercial_classification_of_organizations.csv')
  .describe('outputJSONFiles', 'true or false to (over)write JSON Files')
  .default('outputJSONFiles', 'true')
  .argv

{ csvFilePattern, outputJSONFiles, csvFileCommercialOrganizations, outputFileContributersByEmail, outputFileContributersByName } = options

firms = {}
contributorsByEmail = {}
contributorsByName = {}
validEmail = /^[a-zA-Z0-9.!#$%&'*+/=?^_{|} ̃-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
outputJSONFiles = if outputJSONFiles is 'true' then true else false

# so that Alice Smith === alice smith
uniformString = (s) -> s.toLowerCase().trim()

csv.parse fs.readFileSync(csvFileCommercialOrganizations).toString(), { columns: true }, (err, orgs) ->
  orgs.forEach (org) ->
    firms[org.login] = org.email_domain if org and org.is_commercial is 'yes' and org.login
  # read all contributors for every firm
  allRegex = {}
  Object.keys(firms).forEach (org) ->
    allRegex[org] ?= new RegExp(firms[org]) if firms[org]

  bar = new ProgressBar '  processing [:bar] :percent :etas',
    complete: '=',
    incomplete: ' ',
    width: 20,
    total: Object.keys(firms).length

  Object.keys(firms).forEach (org, i) ->
    sequence.then (next) ->
      csv.parse fs.readFileSync(csvFilePattern.replace(/\{organization\}/, org)).toString(), { columns: true },(err, data) ->

        data.forEach (person, i) ->
          email = uniformString(person.email)
          if email and validEmail.test(email) and not /@.+noreply\.github\.com$/.test(email) and not /@.+\.local(domain)*$/.test(email)
            names = person.names.split(';')
            contributorsByEmail[email] ?= {
              is_employed_by_firm: false
              names: []
              potential_firms: []
            }
            if contributorsByEmail[email].potential_firms.indexOf(org) is -1
              contributorsByEmail[email].potential_firms.push(org)
            if contributorsByEmail[email].is_employed_by_firm is false
              Object.keys(allRegex).forEach (orgKey) ->
                regex = allRegex[orgKey]
                if regex.test(email)
                  if contributorsByEmail[email].is_employed_by_firm is false
                    contributorsByEmail[email].is_employed_by_firm = orgKey
                  # contributorsByEmail[email].potential_firms.push(orgKey) if contributorsByEmail[email].potential_firms.indexOf(orgKey) is -1
            names.forEach (name) ->
              name = uniformString(name)
              return if name is 'uknown'
              contributorsByEmail[email].names.push(name) if contributorsByEmail[email].names.indexOf(name) is -1
              contributorsByName[name] ?= {
                emails: []
                is_employed_by_firms: []
                potential_firms: []
              }
              contributorsByName[name].emails.push(email) if contributorsByName[name].emails.indexOf(email) is -1
              orgKey = contributorsByEmail[email].is_employed_by_firm
              if orgKey
                contributorsByName[name].is_employed_by_firms.push(orgKey) if contributorsByName[name].is_employed_by_firms.indexOf(orgKey) is -1
        bar.tick(1)
        next()

  sequence.then ->
    if outputJSONFiles
      for email of contributorsByEmail
        if contributorsByEmail[email].potential_firms.length > 0
          contributorsByEmail[email].potential_firms = _.uniqBy(contributorsByEmail[email].potential_firms)
      for name of contributorsByName
        if contributorsByName[name].potential_firms.length > 0
          contributorsByName[name].potential_firms = _.uniqBy(contributorsByName[name])
      [ { file: outputFileContributersByEmail, data: contributorsByEmail }, { file: outputFileContributersByName, data: contributorsByName } ].forEach (batch) ->
        { file, data } = batch
        console.error "\n  --> Writing JSON File '#{file}'"
        fs.writeFile(file, JSON.stringify(data, null, 2))

    percentageOfContribution = {}

    csv.parse fs.readFileSync('../data/csv/calculated/top_external_contributors.csv').toString(), { columns: true }, (err, topContributors) ->
      topContributors.forEach (cont) ->
        if typeof percentageOfContribution[uniformString(cont['author.email'])] is 'undefined' or cont['percentage_of_contribution'] > percentageOfContribution[uniformString(cont['author.email'])]
          percentageOfContribution[uniformString(cont['author.email'])] = cont['percentage_of_contribution']


      # console.log percentageOfContribution
      # process.exit(0)
      fields = 'email,percentage_of_contribution,names,all_names,is_employed_by_firm,potential_firms'.split(',')
      console.log '"'+fields.join('","')+'"'
      for email of contributorsByEmail
        contributor = contributorsByEmail[email]
        #contributor.names.forEach (name) ->
        byFirm = if contributor.is_employed_by_firm then contributor.is_employed_by_firm else ''
        contributor.names.forEach (name, i) ->
          name = name.replace(/(\(.*?\)|\[.*?\])$/,'').trim()
          contributor.names[i] = name

        relevantNames = _.remove contributor.names, (n) -> (Boolean) n.trim().indexOf(' ') >= 0
        percentageOfContr = percentageOfContribution[email] or -1
        percentageOfContr = 0 if percentageOfContr > 1 # some values are above 1 ?!
        # query = "site:linkedin.com #{email} '#{relevantNames.join('" | "')}' (#{contributor.potential_firms.join(' | ')})"
        data = [ email, percentageOfContr, relevantNames.join('|'), contributor.names.join('|'), byFirm, contributor.potential_firms.join('|') ]
        console.log '"'+data.join('","')+'"'
