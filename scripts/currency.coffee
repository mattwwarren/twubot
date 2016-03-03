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
TIMEOUT_MINUTES = process.env.HUBOT_CREDITS_TIMEOUT * 60 * 1000 ? 60000
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []


module.exports = (robot) ->
  moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS

  cronJob = require('cron').CronJob
  tz = 'America/New_York'

  earnCredits = ->
    creds = robot.brain.get('credits') or {}
    console.log("Creds? : " + JSON.stringify(creds))
    for user in Object.keys(creds)
      console.log("OLD BANK: " + creds[user]['bank'])
      balance = creds[user]['bank'] ? 0
      balance = parseInt(balance)
      balance += parseInt(EARNINGS_PER_TIMEOUT)
      creds[user]['bank'] = balance
      console.log("OLD BANK: " + creds[user]['bank'])
    robot.brain.set 'credits', creds
  new cronJob('0 */1 * * * *', earnCredits, null, true)
 
  robot.enter (msg) ->
    creds = robot.brain.get('credits') or {} 
    user = msg.envelope.user.name
    now = new Date().getTime()
    if user not in Object.keys(creds)
      creds[user] = {}
      balance = creds[user]['bank'] ? 0
      balance = parseInt(balance)
      balance += 50
      creds[user]['bank'] = balance
    creds[user]['lastJoined'] = now
    if not creds[user]['firstJoined']?
      creds[user]['firstJoined'] = now

    robot.brain.set 'credits', creds

  robot.hear /!give (\w+) (\d+)/i, (msg) ->
    creds = robot.brain.get('credits') or {}
    user = msg.match[1]
    amount = msg.match[2]
    balance = creds[user]['bank'] ? 0
    balance = parseInt(balance)
    balance += parseInt(amount)
    creds[user]['bank'] = balance
    robot.brain.set 'credits', creds
    msg.send "Gave #{user} #{amount} credits!"

  robot.hear /!balance/i, (msg) ->
    creds = robot.brain.get('credits') or {}
    user = msg.envelope.user.name
    balance = creds[user]['bank'] ? 0
    balance = parseInt(balance)
    msg.send "#{user}, your balance is #{balance}!"

  robot.hear /!giveall (\d+)/i, (msg) ->
    creds = robot.brain.get('credits') or {} 
    amount = msg.match[1]
    for user in Object.keys(creds)
      balance = creds[user]['bank'] ? 0
      balance = parseInt(balance)
      balance += parseInt(amount)
      creds[user]['bank'] = balance
    
    robot.brain.set 'credits', creds
    msg.send "Gave everyone #{amount} credits!"

