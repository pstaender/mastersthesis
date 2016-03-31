#!/usr/bin/env coffee

# didn't help at all…
# script is left in repo for the sake of completeness

fs = require('fs')
csv = require('csv')
_ = require('lodash')
CSON = require 'cson-parser'

options = require('yargs')
  .help('h')
  .alias('h', 'help')
  .describe('file', 'csv file')
  .describe('id', 'id of user')
  .default('id', '0')
  .describe('email', 'email of user')
  .default('email', '')
  .describe('name', 'name of user')
  .default('name', '')
  .describe('returnValue', 'firm or logical')
  .default('returnValue', 'firm')
  # .demand(['file'])
  .argv

{ id, email, name, returnValue } = options

id = Number(id)

if file?.trim()
  if not fs.lstatSync(file)
    console.error("File '#{file}' doesnt exists / isnt readable")
    process.exit(1)
  else
    stream = fs.createReadStream(file)
else
  stream = process.stdin


mysql = require('mysql')
connection = mysql.createConnection
  host: 'localhost'
  user: 'root'
  password: 'w97T4g58Mctd'
  database: 'ghtorrent'


# findOrganizationsByUserID = (id, cb) ->
#   connection.query "SELECT * FROM organization_members WHERE user_id = #{id}", cb
#
# finalValue = (value) ->
#   if typeof value is 'string'
#     if returnValue is 'logical'
#       console.log('true')
#     else
#       console.log(value)
#   else
#     if returnValue is 'logical'
#       console.log('false')
#   connection.end()
#   process.exit(0)

fields="login,url,blog,location,email,email_pattern,is_commercial,is_initiated_by_company,name,company,description,public_repos,public_gists,top_repos,created_at,updated_at,organization_id,member_since,type,fake,deleted,user_id".split(',')

console.log "\"#{fields.join('","')}\""
connection.connect()

connection.query "select * from organizations", (err, rows, fields) ->
  throw err if err
  rows.forEach (organization) ->
    #if row.id
    organization.organization_id = organization.id
    connection.query "select * from organization_members where org_id = #{organization.organization_id}", (err, members) ->
      members.forEach (member) ->
        member.member_since = member.created_at
        connection.query "select * from users where id = #{member.user_id} limit 1", (err, rows) ->
          data = {}
          user = rows[0]
          user.user_id = user.id
          delete(user.id)
          for attr of user
            data[attr] = user[attr] unless data.hasOwnProperty(attr)
          for attr of member
            data[attr] = member[attr] unless data.hasOwnProperty(attr)
          for attr of organization
            data[attr] = organization[attr] unless data.hasOwnProperty(attr)

          # d = fields.map (fieldName) ->
          #   data[fieldName]
          console.log data
          #
          # console.log "\"#{d.join('","')}\""


  # if rows[0]?.id
  #   findOrganizationsByUserID rows[0]?.id, (err, rows) ->
  #     throw err if err
  #     if rows.length > 0
  #       ids = rows.map (row) ->
  #         row?.org_id
  #       sqlQuery = "SELECT login FROM organizations WHERE id IN (#{ids.join(',')})"
  #       console.error sqlQuery
  #       connection.query sqlQuery, (err, rows, fields) ->
  #         throw err if err
  #         if rows.length > 0
  #           logins = rows.map (row) ->
  #             row.login
  #           finalValue(logins.join(','))
  #         else
  #           finalValue(null)
  #     else
  #       finalValue(null)
  # else
  #   finalValue(null)
  # return
