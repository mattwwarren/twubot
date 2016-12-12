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
MAX_GIVEAWAY_CHANCES = process.env.HUBOT_GIVEAWAY_CHANCES || 10
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []
ROOM = process.env.HUBOT_TWITCH_CHANNELS

robotBrain = require '../lib/brain'
currency = require '../lib/currency'
moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS

class Giveaway
  constructor: (@robot) ->
    @brain = new robotBrain.BrainSingleton.get @robot
    @counts = @brain.get('giveaway') ? {}
    @curr = new currency.Currency @robot
   
  startGiveaway: (item, user) -> 
    giveawayInfo = {'entries': []}
    giveawayStatus = @brain.get('giveaway') || 'ready'
    if user not in moderators
      return "You are not a moderator. You cannot authorize a giveaway!"
    else
      if giveawayStatus == 'ready'
        giveawayInfo['item'] = item
        @brain.set 'giveaway', 'inprogress'
        @brain.set 'giveaway_info', giveawayInfo
        return "The giveaway has launched! Cough up #{GIVEAWAY_COST} credits for a chance to win! Use !win to enter the drawing."
      else
        return "A giveaway is already in progress. Use !checkGiveaway for details"

  enterGiveaway: (user, entries) ->
    if @brain.get('giveaway') == 'inprogress'
      if entries < 1
        return 'you can\'t enter negative times!'
      if user in moderators
        return 'moderators cannot enter the giveaway. You\'re already special!'
      giveawayInfo = @brain.get('giveaway_info')
      if giveawayInfo[user]
        giveawayAttempts = giveawayInfo[user]['attempts'] + entries
      else
        giveawayAttempts = entries
        giveawayInfo[user] = {}
      if giveawayAttempts <= MAX_GIVEAWAY_CHANCES
        balance = @curr.payCredits user, GIVEAWAY_COST * entries
        if balance >= 0
          giveawayInfo[user]['attempts'] = giveawayAttempts
          giveawayInfo['entries'].push user
          @brain.set 'giveaway_info', giveawayInfo
          return "you are in for the giveaway. Your remaining balance is #{balance} and you can attempt an additional #{MAX_GIVEAWAY_CHANCES - giveawayAttempts} times."
        else
          return "you don't have enough credits to enter the giveaway. Sorry."
      else
        return "you have entered the maximum allowed entries."
    else
      return "there is no giveaway in progress."

  closeGiveaway: (user) ->
    if user not in moderators
      return "You are not a moderator. You cannot close a giveaway!"
    else if @brain.get('giveaway') == 'inprogress'
      @robot.emit 'giveawayEvent', ROOM, 'The giveaway is closed! We will now tally the entries'
      giveawayInfo = @brain.get('giveaway_info')
      entries = giveawayInfo['entries']
      winner = entries[Math.floor(Math.random() * entries.length)]
      @robot.emit 'giveawayEvent', ROOM, 'And the winner is........'
      @brain.set 'giveaway', 'unclaimed'
      return "#{winner}! Please whisper one of #{moderators} to claim your prize!"
    else
      return "There is no giveaway in progress!"

module.exports = (robot) ->
  giveaway = new Giveaway robot

  robot.hear /^!giveaway (.*)$/i, (msg) ->
    giveawayItem = msg.match[1]
    console.log giveawayItem
    user = msg.envelope.user.name.toLowerCase()
    resp = giveaway.startGiveaway giveawayItem, user
    msg.send resp

  robot.hear /^!win( \d+)?$/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    entries = parseInt((msg.match[1] ? '1').trim())
    resp = giveaway.enterGiveaway user, entries
    msg.reply resp

  robot.hear /^!closeGiveaway$/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    resp = giveaway.closeGiveaway user
    msg.send resp

  robot.on 'giveawayEvent', (room = "", message = "") ->
    robot.messageRoom room, message
