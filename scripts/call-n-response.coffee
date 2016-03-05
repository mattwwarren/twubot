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
    keys_regex = new RegExp("^!(" + Object.keys(cnr).join("|") + ")", "i")
    robot.hear keys_regex, (res) ->
      res.send cnr[res.match[1]]

  # List all commands (or not, if there are a ton)
  robot.hear /!commandlist/i, (msg) ->
    cnr = robot.brain.get('call-n-response') or {}
    resp = "Available commands: "
    totalCommands = 0
    for command in Object.keys(cnr)
      totalCommands += 1
      if totalCommands == 1
        resp = resp + command
      else
        resp = resp + ", " + command
    if totalCommands > 20
      msg.send("Oh my, there are #{totalCommands} in the system! " +
               "There's no way I could list them all!")
    else
      msg.send(resp)
