# Description:
#   Count arbitrary events
# 
# Notes:
#
# Usage:
#   !count {event} - increments the event count by one
#
class Counts
  constructor: (@robot) ->
    @counts = {}
    
    @robot.brain.on 'loaded', =>
      if @robot.brain.data.counts
        @counts = @robot.brain.data.counts

  addCount: (toCount) ->
    currCount = @counts[toCount] + 1 || 1
    @counts[toCount] = currCount
    @robot.brain.set "counts", @counts
    return currCount

  getCount: (toCount) ->
    occurences = @counts[toCount]
    if occurences
      return @counts[toCount]
    else
      return -1

module.exports = (robot) ->
  counts = new Counts robot

  robot.hear /!checkCount (.*)$/i, (msg) ->
    toCount = msg.match[1]
    resp = counts.getCount toCount
    if resp > 0
      msg.send "#{toCount} has happened #{resp} times"
    else
      msg.send "#{toCount} has not happened yet. Record it with !count"

  robot.hear /!count (.*)$/i, (msg) ->
    toCount = msg.match[1]
    resp = counts.addCount toCount
    msg.send "#{toCount} now at #{resp}"
