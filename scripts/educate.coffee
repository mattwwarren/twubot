# Description:
#   Allows additions to the call and response file
# 
# Notes:
#   Current version requires data file to be created with a blank object before running bot
#   Example blank object: {}
#   Assumes admins and owner are set as HUBOT_TWITCH_ADMINS and HUBOT_TWITCH_OWNERS
#
# Usage:
#   !add call "potentially super long response"
#

fs = require 'fs'
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []

module.exports = (robot) ->
  moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS
  data = robot.brain.get('call-n-response') or {}
  robot.hear /!learn (\w+) (.*)/i, (msg) ->
    if msg.envelope.user.id not in moderators
      console.log(msg.envelope.user.id + " not in " + moderators.join ",")
      msg.send "I'm sorry, I can't let you do that."
    else
      call = msg.match[1]
      response = msg.match[2]
      data[call] = response
      robot.brain.set 'call-n-response', data
      msg.send "Added command " + call
