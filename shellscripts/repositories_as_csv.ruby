#!/usr/bin/env ruby

require 'pathname'
require 'json'

fields = 'is_top_repository,created_at,updated_at,commits_count,contributors_count,closed_issues_count,open_issues_count,issues_count,license,subscribers_count'
# defaultValues = '0,0,0,0,0,,0'.split(',')

result = {}
delimiter = ','
quote = '"'

$stderr.puts 'Reading Top Repositories'

topRepos = {}


# read to repositories
Dir.glob("#{Dir.pwd}/data/apidata/top_repos_by_language/*.json") do |filename|
  fileContent = File.read(filename)
  data = JSON.parse(fileContent)
  data['items'].each do |repo|
    topRepos[repo['full_name']] = true
  end
end

$stderr.puts 'Collecting repositories data'

puts '"'+('organization_name,repository_name,'+fields).split(',').join('","')+'"'

selectedOrganizationsRepositories = `#{Dir.pwd}/scripts/filter_csv.coffee --file=#{Dir.pwd}/data/csv/all_organizations_repositories.csv --fields="full_name" --where="fork: 'false'" --seperator="," --stringDelimiter=""`

selectedOrganizationsRepositories.split("\n").each do |full_name|
  Dir.glob("#{Dir.pwd}/data/apidata/repositories/#{full_name}/*.json") do |filename|
    # get filename
    fname = Pathname.new(filename).basename.to_s
    basename =  File.basename(fname.to_s, '.json')
    # get repo and organization
    parts = filename.split('/')
    # fname, repo, org = parts[parts.length-1], parts[parts.length-2], parts[parts.length-3]
    fname = parts[parts.length-1]
    org, repo = full_name.split('/')[0], full_name.split('/')[1]
    # ensure structure on nested hash
    result[org] = {} if result[org].nil?
    result[org][repo] = {} if result[org][repo].nil?
    fileContent = File.read(filename)

    result[org][repo]['license'] = '' if result[org][repo]['license'].nil?
    result[org][repo]['is_top_repository'] = false if result[org][repo]['is_top_repository'].nil?

    result[org][repo]['is_top_repository'] = true if topRepos[org+'/'+repo] == true

    result[org][repo]['created_at'] = '' if result[org][repo]['created_at'].nil?
    result[org][repo]['updated_at'] = '' if result[org][repo]['updated_at'].nil?

    # count (once) lines of commits
    if result[org][repo]['commits_count'].nil?
      gitlogfile = "#{Dir.pwd}/data/csv/repositories/logs/logs_#{org}_#{repo}.csv"
      if File.exist?(gitlogfile)
        result[org][repo]['commits_count'] = `cat '#{gitlogfile}' | wc -l`
        result[org][repo]['commits_count'] = result[org][repo]['commits_count'].strip.to_i - 1
        result[org][repo]['commits_count'] -= 1 if result[org][repo]['commits_count'] > 0
      else
        result[org][repo]['commits_count'] = ''
        $stderr.puts "gitlogs missing: #{org}/#{repo}"
      end
    end

    next if fileContent.to_s.strip.length == 0
    begin
      data = JSON.parse(fileContent)
      if basename.to_s =~ /^contributors_/i
        # count contributors
        result[org][repo]['contributors_count'] = data.length
      elsif basename.to_s =~ /^issues_/i
        # count open + closed issues
        result[org][repo]['closed_issues_count']  = 0
        result[org][repo]['open_issues_count']    = 0
        result[org][repo]['issues_count']         = data.length
        data.each do |issue|
          if issue['state'] === 'open'
            result[org][repo]['open_issues_count'] += 1
          else
            result[org][repo]['closed_issues_count'] += 1
          end
        end
      elsif basename.to_s =~ /^repository_/i
        # get license key (if available)
        result[org][repo]['license'] = ''
        result[org][repo]['created_at'] = data['created_at']
        result[org][repo]['updated_at'] = data['updated_at']
        if data and data['license'] and data['license']['key']
          result[org][repo]['license'] = data['license']['key']
        end
      elsif basename.to_s =~ /^subscribers_/i
        result[org][repo]['subscribers_count'] = data.length
      end
    rescue JSON::ParserError => e
      $stderr.puts e.message + " - file #{filename}"
    end

    values = []

    fields.split(',').each do |field|
      values.push(result[org][repo][field]) unless result[org][repo][field].nil?
    end

    if values.length == fields.split(',').length
      print "#{quote}#{org}#{quote}#{delimiter}#{quote}#{repo}#{quote}#{delimiter}"
      print quote+values.join("#{quote}#{delimiter}#{quote}")+quote+"\n"
    end

  end

end
