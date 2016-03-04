# Description:
#   Gives people fake money for watching the stream
# 
# Configuration:
#   HUBOT_CREDITS_PER_X - number of credits to earn on an interval
#   HUBOT_CREDITS_TIMEOUT - interval on which credits are earned
#
# Notes:
#

EARNINGS_PER_TIMEOUT = process.env.HUBOT_CREDITS_PER_X ? 15
TIMEOUT_MINUTES = process.env.HUBOT_CREDITS_TIMEOUT ? 15
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []


module.exports = (robot) ->
  moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS

  createUser = (user, creds) ->
    if user not in Object.keys(creds)
      creds[user] = {}
      balance = creds[user]['bank'] ? 0
      balance = parseInt(balance)
      creds[user]['bank'] = balance
      

  cronJob = require('cron').CronJob
  # Default value, completely useless. Should never have to change
  # Since we are running the cron all the time, timezone doesn't matter
  tz = 'America/New_York'

  # Function to give everyone the appropriate amount of credits
  earnCredits = ->
    creds = robot.brain.get('credits') or {}
    for user in Object.keys(creds)
      if creds[user]['active'] == 'true'
        balance = creds[user]['bank'] ? 0
        balance = parseInt(balance)
        balance += parseInt(EARNINGS_PER_TIMEOUT)
        creds[user]['bank'] = balance

    robot.brain.set 'credits', creds

  # Run the credit giver on each interval
  new cronJob("0 */#{TIMEOUT_MINUTES} * * * *", earnCredits, null, true)
 
  # On user enter, add to brain if not already there
  # Give 50 credits just for coming by
  robot.enter (msg) ->
    creds = robot.brain.get('credits') or {} 
    user = msg.envelope.user.name
    now = new Date().getTime()
    if user not in Object.keys(creds)
      createUser user, creds
      balance = parseInt(creds[user]['bank'])
      balance += 50
      creds[user]['bank'] = balance
    creds[user]['lastJoined'] = now
    creds[user]['active'] = 'true'
    if not creds[user]['firstJoined']?
      creds[user]['firstJoined'] = now

    robot.brain.set 'credits', creds

  # On leave, mark user inactive, stop giving credits
  robot.leave (msg) ->
    creds = robot.brain.get('credits') or {}
    user = msg.envelope.user.name
    if user in Object.keys(creds)
      creds[user]['active'] = 'false'
    
    robot.brain.set 'credits', creds

  # Give a user an arbitary number of credits
  robot.hear /^!give (\w+) (\d+)/i, (msg) ->
    if msg.envelope.user.name not in moderators
      msg.send("Nice try! Not going to happen though.")
    else
      creds = robot.brain.get('credits') or {}
      user = msg.match[1]
      amount = msg.match[2]
      if user not in Object.keys(creds)
        createUser user, creds
      balance = creds[user]['bank'] ? 0
      balance = parseInt(balance)
      balance += parseInt(amount)
      creds[user]['bank'] = balance
      robot.brain.set 'credits', creds
      msg.send "Gave #{user} #{amount} credits!"
 
  # User wants their balance
  robot.hear /^!balance/i, (msg) ->
    creds = robot.brain.get('credits') or {}
    user = msg.envelope.user.name
    if user not in Object.keys(creds)
      createUser user, creds
    balance = creds[user]['bank'] ? 0
    balance = parseInt(balance)
    msg.send "#{user}, your balance is #{balance}!"
  
  # Give all users credits!
  robot.hear /^!giveall (\d+)/i, (msg) ->
    if msg.envelope.user.name not in moderators
      msg.send("Nice try! Not going to happen though.")
    else
      creds = robot.brain.get('credits') or {} 
      amount = msg.match[1]
      for user in Object.keys(creds)
        if creds[user]['active'] == 'true'
          balance = creds[user]['bank'] ? 0
          balance = parseInt(balance)
          balance += parseInt(amount)
          creds[user]['bank'] = balance
    
      robot.brain.set 'credits', creds
      msg.send "Gave everyone #{amount} credits!"

