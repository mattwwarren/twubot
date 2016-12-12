# Description:
#   Count arbitrary events
# 
# Notes:
#
# Usage:
#   !count {event} - increments the event count by one
#
robotBrain = require '../lib/brain'
class Counts
  constructor: (@robot) ->
    @brain = new robotBrain.BrainSingleton.get @robot
    @counts = @brain.get('counts') ? {}
    
  addCount: (toCount) ->
    currCount = @counts[toCount] ? 0
    currCount += 1
    @counts[toCount] = currCount
    @brain.set "counts", @counts
    return currCount

  getCount: (toCount) ->
    occurences = @counts[toCount]
    if occurences
      return @counts[toCount]
    else
      return -1

  getCounts: () ->
    resp = "Current events: "
    if @counts and Object.keys(@counts).length > 0
      countResp = []
      for item of @counts
        countResp.push "#{@counts[item]} #{item}"
      resp += countResp.join(', ')
    else
      resp += "Nothing. Nothing has happened. Ever."
    return resp

module.exports = (robot) ->
  counts = new Counts robot

  robot.hear /!checkCount (.*)$/i, (msg) ->
    toCount = msg.match[1]
    resp = counts.getCount toCount
    if resp > 0
      msg.send "#{toCount} has happened #{resp} times"
    else
      msg.send "#{toCount} has not happened yet. Record it with !count"

  robot.hear /!counts$/i, (msg) ->
    resp = counts.getCounts()
    msg.send resp

  robot.hear /!count (.*)$/i, (msg) ->
    toCount = msg.match[1]
    resp = counts.addCount toCount
    msg.send "#{toCount} now at #{resp}"
