# Description:
#   Allows additions to the call and response file
# 
# Notes:
#   Current version requires data file to be created with a blank object before running bot
#   Example blank object: {}
#   Assumes admins and owner are set as HUBOT_TWITCH_ADMINS and HUBOT_TWITCH_OWNERS
#
# Usage:
#   !learn call "potentially super long response"
#

HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []

cnr = require '../lib/call-n-response'

module.exports = (robot) ->
  moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS
  callResp = new cnr.CallNResponse robot

  robot.hear /!learn (\w+) (.*)/i, (msg) ->
    if msg.envelope.user.id not in moderators
      msg.send "I'm sorry, I can't let you do that."
    else
      call = msg.match[1]
      response = msg.match[2]
      reply = callResp.addResponse call, response
      msg.send reply
