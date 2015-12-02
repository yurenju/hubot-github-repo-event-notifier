#! /usr/bin/env coffee

#commit_comment,create,delete,deployment,deployment_status,fork,gollum,issue_comment,issues,member,membership,page_build,pull_request_review_comment,pull_request,push,repository,release,status,ping,team_add,watch

githubSlackMapping =
  'nickbuddendotcom': 'nick'

unique = (array) ->
  output = {}
  output[array[key]] = array[key] for key in [0...array.length]
  value for key, value of output

extractMentionsFromBody = (body) ->
  mentioned = body.match(/(^|\s)(@[\w\-\/]+)/g)

  if mentioned?
    mentioned = mentioned.filter (nick) ->
      slashes = nick.match(/\//g)
      slashes is null or slashes.length < 2

    mentioned = mentioned.map (nick) ->
      nick = nick.trim().substr(1)
      if githubSlackMapping[nick]
        githubSlackMapping[nick]
      else
        nick
    mentioned = unique mentioned
    mentioned
  else
    null

module.exports =
  commit_comment: (data, callback) ->
    comment = data.comment
    repo = data.repository

    mentioned = extractMentionsFromBody comment.body
    if mentioned
      callback "You have been mentioned by #{comment.user.login}
      on Commit #{comment.commit_id}: #{comment.body} - #{comment.html_url}", mentioned
    else
      callback()

  issue_comment: (data, callback) ->
    issue = data.issue
    comment = data.comment
    repo = data.repository

    issue_pull = "Issue"

    if comment.html_url.indexOf("/pull/") > -1
      issue_pull = "Pull Request"

    mentioned = extractMentionsFromBody comment.body
    if mentioned
      callback "You have been mentioned on #{issue_pull} \##{issue.number} by
      #{comment.user.login}: \"#{comment.body}\" - #{comment.html_url}", mentioned
    else
      callback()

  pull_request_review_comment: (data, callback) ->
    comment = data.comment
    pull_req = data.pull_request
    base = data.base
    repo = data.repository

    mentioned = extractMentionsFromBody comment.body
    if mentioned
      callback "You have been mentioned on Pull Request \"#{comment.body}\" by
      #{comment.user.login}: #{comment.html_url}", mentioned
    else
      callback()
