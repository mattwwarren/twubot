# Description:
#   Simple answer to any given command.
# 
# Notes:
#   Current version requires data file to be created with a blank object before running bot
#   Example blank object: {}
#
# Usage:
#   call - the response found in the data file will be sent in return
#

cnr = require '../lib/call-n-response'

module.exports = (robot) ->

  callResp = new cnr.CallNResponse robot
  # Okay, this is gross but the brain isn't ready until after the scripts
  # have loaded. To avoid not having brain data for the real "hear" event
  # we wrap the whole thing in a listen for any messages.
  # AFAICT, this does not break any other listening
  robot.hear /.*/i, (allmsgs) ->

    robot.hear callResp.callRegex, (res) ->
      res.send callResp.getResponse res.match[1]

  # List all commands (or not, if there are a ton)
  robot.hear /!commandlist/i, (msg) ->
    resp = callResp.getAllResponses()
    msg.send(resp)
