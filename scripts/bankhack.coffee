# Description:
#   Lets people waste all their fake money
# 
# Configuration:
#   HUBOT_BANKHACK_TIMEOUT - interval on which credits are earned
#
# Notes:
#

BANKHACK_MINUTES = process.env.HUBOT_BANKHACK_TIMEOUT ? 15
BANKHACK_WAGER_TIME = (process.env.HUBOT_BANKHACK_WAGER_TIME ? 2) * 60 * 1000
BANKHACK_WIN_RATE = process.env.HUBOT_BANKHACK_WIN ? 50
BANKHACK_WIN_MULTIPLIER = process.env.HUBOT_BANKHACK_MULTIPLIER ? 2
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []
HUBOT_TWITCH_CHANNELS = process.env.HUBOT_TWITCH_CHANNELS?.split "," || []
ROOM = process.env.HUBOT_TWITCH_CHANNELS

moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS
oceansThirteen = ['George Clooney', 'Brad Pitt', 'Matt Damon', 'Al Pacino',
                  'Don Cheadle', 'Bernie Mac', 'Casey Affleck']

currency = require '../lib/currency'
robotBrain = require '../lib/brain'

class Bankhack
  constructor: (@robot) -> 
    @brain = new robotBrain.BrainSingleton.get @robot
    @curr = new currency.Currency @robot
    @wagers = @brain.get('hack_wagers') ? {}

  performHack: ->
    hackChance = Math.floor(Math.random() * 100)
    userCount = 0
    totalWin = 0
    totalLoss = 0
    result = ""
    if hackChance < BANKHACK_WIN_RATE
      for user in Object.keys(@wagers)
        currBalance = @curr.getBalance user
        winnings = parseInt(@wagers[user]) * BANKHACK_WIN_MULTIPLIER
        totalWin += winnings
        userCount += 1
        @curr.updateCredits user, winnings
      result = "Success! #{userCount} high rollers made it " +
             "out alive with #{totalWin} credits."
    else
      for user in Object.keys(@wagers)
        losings = parseInt(@wagers[user])
        totalLoss += losings
        userCount += 1
      result = "Oh no! We're busted. #{userCount} fools " +
             "lost #{totalLoss} credits. But not to " +
             "worry, another chance at glory is up in " +
             "#{BANKHACK_MINUTES} minutes!"
    @robot.emit 'hackMessage', ROOM, result
    @brain.set 'hack_wagers', {}
    @brain.set 'bankhack', 'unready'

  hackReminder: ->
    userCount = 0
    totalBets = 0
    for user in Object.keys(@wagers)
      wager = parseInt(@wagers[user])
      totalBets += wager
      userCount += 1
    reminder = "Did you wager yet? The bank is almost broken." +
           " Put your credits up to bet with !bankhack " +
           "{amount}. #{userCount} players are already " +
           "in for #{totalBets}!"
    @robot.emit 'hackMessage', ROOM, reminder

  hackReady: ->
    @brain.set 'bankhack', 'ready'
    @brain.set 'hack_wagers', {}

  hackJoin: (user, wager) ->
    if @brain.get('bankhack') == 'ready'
      current_wager = 0
      payment = @curr.payCredits user, wager

      if payment < 0
        return "Trying to be slick, #{user}? You don't have enough credits" +
               " to wager #{wager}!"
      else 
        if user not in Object.keys(@wagers)
          current_wager = wager
        else
          current_wager = parseInt(@wagers[user])
          current_wager += wager

        @wagers[user] = current_wager
        @brain.set 'hack_wagers', @wagers
        return "#{user} is in for #{current_wager}."
    else
      return "Sorry, the heat is too hot. Stay out of the kitchen!" 

module.exports = (robot) ->
  bankhack = new Bankhack robot
  cronJob = require('cron').CronJob
  # Function to alert the room the hack is on!
  hackAlert = ->
    hacker = oceansThirteen[Math.floor(Math.random() * oceansThirteen.length)]
    robot.messageRoom ROOM, "Oh noes! #{hacker} is breaking into the bank. " + 
                            "Get ready to reap all the sweet rewards. Type " +
                            "!bankhack {amount} to wager and win!"
    bankhack.hackReady()

    # Note: the comma is not indented on the same spacing as performHack.
    setTimeout ( ->
      bankhack.hackReminder()
    ), BANKHACK_WAGER_TIME / 2

    setTimeout ( -> 
      bankhack.performHack()
    ), BANKHACK_WAGER_TIME

  # Run bankhack on each interval
  new cronJob("0 */#{BANKHACK_MINUTES} * * * *", hackAlert, null, true)

  # Take a users hack wager
  robot.hear /^!bankhack (\d+)/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    wager = parseInt(msg.match[1])
    resp = bankhack.hackJoin user, wager
    msg.send resp
 
  robot.on 'hackMessage', (room = "", message = "") ->
    robot.messageRoom room, message
