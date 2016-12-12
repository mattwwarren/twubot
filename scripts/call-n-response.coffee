# Description:
#   Simple answer to any given command or add commands.
# 
# Notes:
#   Things in here are a little hacky. We have to do some
#   fun intialization magic with respect to the hubot brain.
#
# Usage:
#   call - the response found in the data file will be sent in return
#   !learn call "potentially super long response"
#
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []

cnr = require '../lib/call-n-response'

module.exports = (robot) ->
  moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS
  callResp = new cnr.CallNResponse robot

  # Okay, this is gross but the brain isn't ready until after the scripts
  # have loaded. To avoid not having brain data for the real "hear" event
  # we wrap the whole thing in a listen for any messages.
  # AFAICT, this does not break any other listening
  #robot.hear /.*/i, (allmsgs) ->

  robot.hear callResp.getCallRegex(), (res) ->
    response = callResp.getResponse res.match[1]
    if response
      res.send response

  # List all commands (or not, if there are a ton)
  robot.hear /!commandlist/i, (msg) ->
    resp = callResp.getAllResponses()
    msg.send(resp)

  robot.hear /!learn (\w+) (.*)/i, (msg) ->
    if msg.envelope.user.id not in moderators
      msg.send "I'm sorry, I can't let you do that."
    else
      call = msg.match[1]
      response = msg.match[2]
      reply = callResp.addResponse call, response
      msg.send reply
