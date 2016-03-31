-- # Using data from https://www.githubarchive.org/
--   1. Login into the Google Developer Console
--      (https://console.developers.google.com/)
--   2. Create a project
--      (https://developers.google.com/console/help/#creatingdeletingprojects)
--   3. Activate the BigQuery API
--      (https://developers.google.com/console/help/#activatingapis)
--   4. Open public dataset
--      (https://bigquery.cloud.google.com/table/githubarchive:day.events_20150101)

-- All data is collected since 2011 - 2014

-- Count GitHub users

SELECT COUNT(DISTINCT actor) FROM [githubarchive:github.timeline]

-- --> 4525103
