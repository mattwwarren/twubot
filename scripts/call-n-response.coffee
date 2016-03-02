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

fs = require 'fs'

module.exports = (robot) ->

  # Okay, this is gross but the brain isn't ready until after the scripts
  # have loaded. To avoid not having brain data for the real "hear" event
  # we wrap the whole thing in a listen for any messages.
  # AFAICT, this does not break any other listening
  robot.hear /.*/i, (allmsgs) ->
    cnr = robot.brain.get('call-n-response') or {}
    keys_regex = new RegExp("!(" + Object.keys(cnr).join("|") + ")", "i")
    robot.hear keys_regex, (res) ->
      console.log "match: " + res.match
      console.log "key: " + res.match[1]
      console.log "value: " + cnr[res.match[1]]
      res.send cnr[res.match[1]]
