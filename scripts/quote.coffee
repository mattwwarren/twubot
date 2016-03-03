# Description:
#   Adds quotes the streamer said on stream
# 
# Notes:
#   Assumes admins and owner are set as HUBOT_TWITCH_ADMINS and HUBOT_TWITCH_OWNERS
#
# Usage:
#   !quote thing streamer said on stream
#

fs = require 'fs'
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []

module.exports = (robot) ->
  moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS
  robot.hear /!quote add (.*)/i, (msg) ->
    quotes = robot.brain.get('quotes') or []
    if msg.envelope.user.id not in moderators
      console.log("quote attempted -- " + msg.envelope.user.id + " not in " + moderators.join ",")
      msg.send "I'm sorry, I can't let you do that."
    else
      quotes.push msg.match[1]
      robot.brain.set 'quotes', quotes
      msg.send "Added quote. Quote count at " + quotes.length

  robot.hear /!quote random/i, (msg) ->
    quotes = robot.brain.get('quotes') or []
    msg.send msg.random quotes
