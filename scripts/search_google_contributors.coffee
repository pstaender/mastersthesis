require('request')
fs = require('fs')
path = require('path')
csv = require('csv')
google = require('google')
Sequence = require('sequence').Sequence
sequence = Sequence.create()
_ = require('lodash')

csvFilePotentialFirmEmployedContributors = '../data/csv/potential_firm_employed_contributors.csv'

# i = 0

google.resultsPerPage = 5

fields = 'x,email,names,potential_firms,firm,title,link,description,href,rank'.split(',')

fields = 'x,done,email,names,potential_firms,query,ratio'.split(',')

console.log "\"#{fields.join('","')}\""

csv.parse fs.readFileSync(csvFilePotentialFirmEmployedContributors).toString(), { columns: true }, (err, contributors) ->
  contributors.forEach (contributor, i) ->
    if not contributor.is_employed_by_firm and Number(contributor['percentage_of_contribution']) > 0
      do (i, contributor) ->
        sequence.then (next) ->
          console.error "[#{i}]\t #{contributor.email}"
          query = []
          query.push('site:linkedin.com')
          names = contributor.names.split('|')
          if names.length is 0
            name = contributor.email
          else if names.length is 1
            name = names[0]

          query.push(name)
          query.push(contributor.potential_firms.split('|').join(' '))

          query = encodeURI(query.join(' '))

          query = "https://www.google.de/search?q=#{query}&oq=#{query}&aqs=chrome..69i57j69i60l5.2838j0j7&sourceid=chrome&es_sm=119&ie=UTF-8"

          foundRelevantResult = false

          console.log '"'+[ i, '', contributor.email, contributor.names, contributor.potential_firms, query, contributor['percentage_of_contribution'] ].join('","')+'"'
          return next()

          contributor.potential_firms.split('|').forEach (firm) ->
            return if foundRelevantResult isnt false
            finalQuery = query.slice()
            finalQuery.push(firm)
            console.error "\t search -> " + finalQuery.join(' ')
            # if contributor.names.split('|').join()

            google finalQuery.join(' '), (err, next, links) ->
              throw err if err
              links?.forEach (link, rank) ->
                return if foundRelevantResult isnt false
                # console.log link
                if link.description.toLowerCase().indexOf(name.trim().toLowerCase()) >= 0 and link.description.toLowerCase().indexOf(firm.trim().toLowerCase())
                  foundRelevantResult = link
                  foundRelevantResult.firm = firm
                  foundRelevantResult.rank = rank
                  foundRelevantResult.description = foundRelevantResult.description.replace(/\n+/g,' ').trim()

              data = [ i, contributor.email, contributor.names, contributor.potential_firms ]
              if foundRelevantResult
                data = data.concat([foundRelevantResult.firm, foundRelevantResult.title, foundRelevantResult.link, foundRelevantResult.description, foundRelevantResult.href, foundRelevantResult.rank ])
              console.log "\"#{data.join('","')}\""
              next()






# { email: 'marius@monkey.org',
#   percentage_of_contribution: '1',
#   names: 'marius a. eriksen',
#   all_names: '',
#   is_employed_by_firm: '',
#   potential_firms: 'twitter' }


#
#   console.log err, next, links
