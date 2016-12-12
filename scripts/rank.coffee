# Description:
#   Create, purchase and manage ranks
# 
# Configuration:
#
# Notes:
#

HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []
HUBOT_TWITCH_RANK_PRICE = process.env.HUBOT_TWITCH_RANK_PRICE || 20000

_ = require 'underscore'
currency = require '../lib/currency'
robotBrain = require '../lib/brain'

class Ranks
  constructor: (@robot) -> 
    @brain = new robotBrain.BrainSingleton.get @robot
    @ranks = @brain.get('ranks') ? {}
    @users = @brain.getUsers() ? {}
    @curr = new currency.Currency @robot

  addRank: (cost, rank) ->
    if rank of @ranks
      return "Sorry, #{rank} already exists as a rank"
    else
      @ranks[rank] = cost
      @brain.set 'ranks', @ranks
      return "#{rank} is now available as a rank. Pay up #{cost} credits to join"

  joinRank: (rank, user) ->
    if rank of @ranks
      cost = @ranks[rank]
      balance = @curr.getBalance user
      userObj = @users[user] ? {}
      if balance >= cost
        uranks = userObj.ranks ? []
        if rank in uranks
          return "um, you're already in #{rank}"
        else
          uranks.push rank
          userObj.ranks = uranks
          @curr.payCredits user, cost
          @users[user] = userObj
          @brain.setUsers @users
          return "you are now a member of #{rank}!"
      else
        return "Sorry, you don't have enough credits to join #{rank}. You need #{cost}."
    else
      return "Sorry, #{rank} is not a valid rank. Check ranks with !listranks"
    
  listRanks: ->
    resp = 'Available ranks: '
    rankList = []
    if Object.keys(@ranks).length > 0
      for rank of @ranks
        rankCost = @ranks[rank]
        rankList.push "#{rank}: #{rankCost}"
      resp += rankList.join(', ')
    else
      resp += 'none! Add one with !addrank'
    return resp
    
  checkRank: (user) ->
    userRanks = @users[user] and @users[user].ranks ? []
    if userRanks.length > 0
      resp = "#{user} is a member of #{@users[user].ranks.join(', ')}"
    else
      resp = "#{user} is not a member of any rank!"
    return resp

  leaveRank: (rank, user) ->
    if rank of @ranks
      uranks = @users[user] and @users[user].ranks ? []
      if rank in uranks
        uranks.splice uranks.indexOf(rank), 1
        @users[user].ranks = uranks
        @brain.setUsers @users
        return "you are no longer a member of #{rank}!"
      else
        return "um, you're not in #{rank}"
    else
      return "Sorry, #{rank} is not a valid rank. Check ranks with !listranks"

module.exports = (robot) ->
  moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS
  ranks = new Ranks robot

  robot.hear /^!addrank (\d+) (.+)/i, (msg) ->
    rankCost = msg.match[1]
    rankName = msg.match[2]
    if msg.envelope.user.name.toLowerCase() in moderators
      resp = ranks.addRank rankCost, rankName
      msg.send resp
    else
      msg.reply "no can do. You're not an admin."

  robot.hear /^!joinrank (.+)/i, (msg) ->
    rankName = msg.match[1]
    resp = ranks.joinRank rankName, msg.envelope.user.name.toLowerCase()
    msg.reply resp

  robot.hear /^!leaverank (.+)/i, (msg) ->
    rankName = msg.match[1]
    resp = ranks.leaveRank rankName, msg.envelope.user.name.toLowerCase()
    msg.reply resp

  robot.hear /^!listranks?/i, (msg) ->
    resp = ranks.listRanks()
    msg.send resp

  robot.hear /^!checkranks? ?(\w+)?/i, (msg) ->
    user = msg.match[1] || msg.envelope.user.name.toLowerCase()
    resp = ranks.checkRank user
    msg.send resp
