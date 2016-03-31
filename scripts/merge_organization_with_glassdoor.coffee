#!/usr/bin/env coffee

fs = require('fs')
csv = require('csv')
_ = require('lodash')

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('user', 'user')
  .describe('csvFileOrganizations', 'csv file of all classification data')
  .default('csvFileOrganizations', '../data/csv/selected_commercial_organizations.csv')
  .describe('csvFileAllOrganizations', 'csv file of all organizations data')
  .default('csvFileAllOrganizations', '../data/csv/organizations.csv')
  .describe('filesOfGlassdoorApiData', 'csv file of all organizations data')
  .default('filesOfGlassdoorApiData', '../data/apidata/glassdoor/employers/{organization}.json')
  .argv

{filesOfGlassdoorApiData} = options

csvFileOrganizations = fs.readFileSync(options.csvFileOrganizations)
throw Error("CSV file '#{csvFileOrganizations}' for all repos doesnt exists") unless csvFileOrganizations
csvFileAllOrganizations = fs.readFileSync(options.csvFileAllOrganizations)
throw Error("CSV file '#{csvFileAllOrganizations}' for additional repos doesnt exists") unless csvFileAllOrganizations


readGlassdoorApiData = (organizations) ->
  map = {
    'Alibaba.com': 'alibaba'
    'Valve Corporation': 'ValveSoftware'
    'Chef Software': 'chef'
    'id Software': 'id-Software'
    'Amazon.com': 'amazon'
    'Qihoo 360': 'Qihoo360'
    # 'Parse': ''
  }

  data = []

  for orgName of organizations
    org = organizations[orgName]
    name = org.glassdoor_name
    glassdoorData = JSON.parse(fs.readFileSync(filesOfGlassdoorApiData.replace('{organization}',name)).toString())
    found = false
    organizationLogin = org.parent_firm or orgName
    # console.log organizationLogin
    glassdoorData.response.employers.forEach (employer, i) ->
      unless found
        # console.log map[organizationLogin.toLowerCase().trim()]
        if employer.name.trim().toLowerCase() == organizationLogin.trim().toLowerCase() or employer.name.trim().toLowerCase() == organizationLogin.trim().toLowerCase() or map[employer.name] is organizationLogin
          found = employer
    if found
      organizations[orgName] = _.assignIn(organizations[orgName], {
        numberOfRatings: found.numberOfRatings
        overallRating: found.overallRating
        ratingDescription: found.ratingDescription
        cultureAndValuesRating: Number(found.cultureAndValuesRating)
        seniorLeadershipRating: Number(found.seniorLeadershipRating)
        compensationAndBenefitsRating: Number(found.compensationAndBenefitsRating)
        careerOpportunitiesRating: Number(found.careerOpportunitiesRating)
        workLifeBalanceRating: Number(found.workLifeBalanceRating)
        recommendToFriendRating: Number(found.recommendToFriendRating)
        sectorName: found.sectorName
        industry: found.industry
        industryName: found.industryName
      })
      data.push(organizations[orgName])
    else
      console.error "Warning: Could not find appropiate glassdoor record for #{organizationLogin} / #{name}"

  csv.stringify data, { header: true }, (err, s) ->
    console.log s


orgs = {}

csv.parse csvFileOrganizations.toString(), { columns: true }, (err, data) ->
  throw err if err
  data.forEach (record) ->
    orgs[record['owner.login']] = record if record.is_commercial is 'yes' and record.glassdoor_name
  csv.parse csvFileAllOrganizations.toString(), { columns: true }, (err, data) ->
    data.forEach (record) ->
      if typeof orgs[record.login] is 'object'
        orgs[record.login] = _.assignIn(orgs[record.login], record)
        'owner.login,company,repos_url,events_url,members_url,members_url,public_members_url,avatar_url,description,public_gists,followers.following,html_url,type'.split(',').forEach (field) ->
          delete(orgs[record.login][field])
    readGlassdoorApiData(orgs)
