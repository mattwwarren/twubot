# Description:
#   Lets people waste all their fake money
# 
# Configuration:
#   HUBOT_BANKHACK_TIMEOUT - interval on which credits are earned
#
# Notes:
#

BANKHACK_MINUTES = process.env.HUBOT_BANKHACK_TIMEOUT ? 5 #15
BANKHACK_WAGER_TIME = (process.env.HUBOT_BANKHACK_WAGER_TIME ? 2) * 60 * 1000
BANKHACK_WIN_RATE = process.env.HUBOT_BANKHACK_WIN ? 75
BANKHACK_WIN_MULTIPLIER = process.env.HUBOT_BANKHACK_MULTIPLIER ? 2
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []
HUBOT_TWITCH_CHANNELS = process.env.HUBOT_TWITCH_CHANNELS?.split "," || []


module.exports = (robot) ->
  moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS
  oceansThirteen = ['George Clooney', 'Brad Pitt', 'Matt Damon', 'Al Pacino',
                    'Don Cheadle', 'Bernie Mac', 'Casey Affleck']

  performHack = ->
    hackChance = Math.floor(Math.random() * 100)
    creds = robot.brain.get('credits') ? {}
    wagers = robot.brain.get('hack_wagers') ? {}
    userCount = 0
    totalWin = 0
    totalLoss = 0
    if hackChance < BANKHACK_WIN_RATE
      for user in Object.keys(wagers)
        currBalance = parseInt(creds[user]['bank'])
        winnings = parseInt(wagers[user]) * BANKHACK_WIN_MULTIPLIER
        totalWin += winnings
        userCount += 1
        creds[user]['bank'] = currBalance + winnings
      robot.brain.set 'credits', creds
      for room in HUBOT_TWITCH_CHANNELS
        robot.messageRoom room, "Success! #{userCount} high rollers made it " +
                                "out alive with #{totalWin} credits."
    else
      for user in Object.keys(wagers)
        losings = parseInt(wagers[user])
        totalLoss += losings
        userCount += 1
      for room in HUBOT_TWITCH_CHANNELS
        robot.messageRoom room, "Oh no! We're busted. #{userCount} fools " +
                                "lost #{totalLoss} credits. But not to " +
                                "worry, another chance at glory is up in " +
                                "#{BANKHACK_MINUTES} minutes!"
    robot.brain.set 'hack_wagers', {}
    robot.brain.set 'bankhack', 'unready'
  
  hackReminder = ->
    for room in HUBOT_TWITCH_CHANNELS
      wagers = robot.brain.get('hack_wagers') ? {}
      userCount = 0
      totalBets = 0
      for user in Object.keys(wagers)
        wager = parseInt(wagers[user])
        totalBets += wager
        userCount += 1
      robot.messageRoom room, "Did you wager yet? The bank is almost broken." +
                              " Put your credits up to bet with !bankhack " +
                              "{amount}. #{userCount} players are already " +
                              "in for #{totalBets}!"

  cronJob = require('cron').CronJob
  # Function to alert the room the hack is on!
  hackAlert = ->
    for room in HUBOT_TWITCH_CHANNELS
      hacker = oceansThirteen[Math.floor(Math.random() * oceansThirteen.length)]
      robot.messageRoom room, "Oh noes! #{hacker} is breaking into the bank. " + 
                              "Get ready to reap all the sweet rewards. Type " +
                              "!bankhack {amount} to wager and win!"
      robot.brain.set 'bankhack', 'ready'
      robot.brain.set 'hack_wagers', {}

      # Note: the comma is not indented on the same spacing as performHack.
      setTimeout ( ->
        hackReminder()
      ), BANKHACK_WAGER_TIME / 2

      setTimeout ( ->
        performHack()
      ), BANKHACK_WAGER_TIME

  # Run bankhack on each interval
  new cronJob("0 */#{BANKHACK_MINUTES} * * * *", hackAlert, null, true)

  # Take a users hack wager
  robot.hear /^!bankhack (\d+)/i, (msg) ->
    if robot.brain.get('bankhack') == 'ready'
      user = msg.envelope.user.name.toLowerCase()
      wager = parseInt(msg.match[1])
      wagers = robot.brain.get('hack_wagers') ? {}
      creds = robot.brain.get('credits') ? {}
      currBalance = parseInt(creds[user]['bank'])
      current_wager = 0

      if currBalance < wager
        msg.send "Trying to be slick, #{user}? You don't have enough credits" +
                 " to wager #{wager}!"
      else 
        if user not in Object.keys(wagers)
          current_wager = wager
        else
          current_wager = parseInt(wagers[user])
          current_wager += wager

        wagers[user] = current_wager
        creds[user]['bank'] = currBalance - wager
        robot.brain.set 'hack_wagers', wagers
        robot.brain.set 'credits', creds
        msg.send "#{user} is in for #{current_wager}."
    else
      msg.send "Sorry, the heat is too hot. Stay out of the kitchen!" 
    
