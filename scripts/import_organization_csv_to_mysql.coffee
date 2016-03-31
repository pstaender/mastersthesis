#!/usr/bin/env coffee

fields="login,id,url,blog,location,email,name,company,repos_url,events_url,members_url,public_members_url,avatar_url,description,public_repos,public_gists,followers,following,html_url,created_at,updated_at,type,number_of_distinct_repos,is_commercial,glassdoor_name,is_initiated_by_company,email_domain".split(',')

options = { }
options.table = 'organizations'
options.dbName = process.env.DBNAME or 'github_csv'
options.dbUser = process.env.DBUSER or 'githubuser'
options.dbPassword = process.env.DBPASSW or 'githubpassw'
options.dbHost = process.env.DBHOST or 'localhost'

{ table } = options

schema = """
DROP TABLE IF EXISTS `#{table}`;
CREATE TABLE `#{table}` (
  `id` int(11) NOT NULL,
  `login` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `blog` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `company` varchar(255) NOT NULL,
  `repos_url` varchar(255) NOT NULL,
  `events_url` varchar(255) NOT NULL,
  `members_url` varchar(255) NOT NULL,
  `public_members_url` varchar(255) NOT NULL,
  `avatar_url` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `public_repos` int(11) NOT NULL,
  `public_gists` int(11) NOT NULL,
  `followers` int(11) NOT NULL,
  `following` int(11) NOT NULL,
  `html_url` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `type` int(11) NOT NULL,
  `number_of_distinct_repos` int(11) NOT NULL,
  `is_commercial` varchar(10) NOT NULL,
  `glassdoor_name` varchar(255) NOT NULL,
  `is_initiated_by_company` varchar(255) NOT NULL,
  `email_domain` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
"""
