# Description:
#   Open a giveaway to viewers
# 
# Configuration:
#   - HUBOT_GIVEAWAY_COST - amount in credits to charge for joining a giveaway (default: 100)
#   - HUBOT_GIVEAWAY_CHANCES - number of giveaway purchases allowed (default: 10)
#
# Notes:
#   
#

GIVEAWAY_COST = process.env.HUBOT_GIVEAWAY_COST || 100
GIVEAWAY_CHANCES = process.env.HUBOT_GIVEAWAY_CHANCES || 10
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []

currency = require '../lib/currency'
moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS

module.exports = (robot) ->
  curr = new currency.Currency robot

  robot.hear /^!giveaway (.*)$/i, (msg) ->
    giveawayItem = msg.match[1]
    giveawayInfo = {'entries': []}
    giveawayStatus = robot.brain.get('giveaway') || 'ready'
    console.log giveawayStatus
    user = msg.envelope.user.name.toLowerCase()
    if user not in moderators
      msg.reply "You are not a moderator. You cannot authorize a giveaway!"
    else
      if giveawayStatus == 'ready'
        giveawayInfo['item'] = giveawayItem
        msg.send "The giveaway has launched! Cough up #{GIVEAWAY_COST} credits for a chance to win! Use !enterGiveaway to enter the drawing."
        robot.brain.set 'giveaway', 'inprogress'
        robot.brain.set 'giveaway_info', giveawayInfo
      else
        msg.send "A giveaway is already in progress. Use !checkGiveaway for details"

  robot.hear /^!enterGiveaway$/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    if robot.brain.get('giveaway') == 'inprogress'
      giveawayInfo = robot.brain.get('giveaway_info')
      if giveawayInfo[user]
        giveawayAttempts = giveawayInfo[user]['attempts']
      else
        giveawayAttempts = 0
        giveawayInfo[user] = {}
      if giveawayAttempts < GIVEAWAY_CHANCES
        balance = curr.payCredits user, GIVEAWAY_COST
        if balance >= 0
          giveawayInfo[user]['attempts'] = giveawayAttempts + 1
          giveawayInfo['entries'].push user
          robot.brain.set 'giveaway_info', giveawayInfo
          msg.reply "you are in for the giveaway. Your remaining balance is #{balance} and you can attempt an additional #{GIVEAWAY_CHANCES - giveawayAttempts} times."
        else
          msg.reply "you don't have enough credits to enter the giveaway. Sorry."
      else
        msg.reply "you have entered the maximum allowed entries."
    else
        msg.send "There is no giveaway in progress."

  robot.hear /^!closeGiveaway$/i, (msg) ->
    if robot.brain.get('giveaway') == 'inprogress'
      msg.send 'The giveaway is closed! We will now tally the entries'
      giveawayInfo = robot.brain.get('giveaway_info')
      entries = giveawayInfo['entries']
      winner = msg.random entries
      msg.send "And the winner is........"
      msg.send "#{winner}! Please whisper one of #{moderators} to claim your prize!"
      robot.brain.set 'giveaway', 'unclaimed'
    else
      msg.send "There is no giveaway in progress!"
      
