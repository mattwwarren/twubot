# Description:
#   Track viewer first joins, follows, and last seen
# 
# Configuration:
#
# Notes:
#
moment = require 'moment'
humanizeDuration = require 'humanize-duration'
channel = process.env.HUBOT_TWITCH_CHANNELS.substr(1)
viewership = require '../lib/viewership.coffee'

module.exports = (robot) ->
  viewers = new viewership.Viewership robot, channel

  robot.enter (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    viewers.userEnter user

  robot.leave (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    viewers.userExit user

  robot.hear /^!lastseen (\w+)/i, (msg) ->
    user = msg.match[1].toLowerCase()
    resp = viewers.getLastSeen user
    msg.send resp

  robot.hear /^!checktime (\w+)/i, (msg) ->
    user = msg.match[1].toLowerCase()
    viewers.checkFollows user, (time) ->
      if time
        now = new Date().getTime()
        followTime = humanizeDuration(moment.duration(now - time.valueOf()), { units: ['y', 'mo', 'd', 'h'], round: true})
        resp = "#{user} has been a part of #{channel} for #{followTime}"
      else
        resp = "#{user} is not following #{channel}"
      msg.send resp

  robot.hear /^!follow (\w+)/i, (msg) ->
    user = msg.match[1].toLowerCase()
    viewers.checkFollows user, (followp) ->
      if followp
        resp = "#{user} started following #{channel} on #{followp.calendar()}"
      else
        resp = "#{user} does not follow #{channel}!"
      msg.send resp

