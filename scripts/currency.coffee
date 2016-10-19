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
TIMEOUT_MINUTES = (process.env.HUBOT_CREDITS_TIMEOUT ? 15 ) * 60 * 1000
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []

currency = require '../lib/currency'

moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS

module.exports = (robot) ->
  curr = new currency.Currency robot

  setTimeout ( ->
    curr.earnCredits(EARNINGS_PER_TIMEOUT)
  ), TIMEOUT_MINUTES
 
  # On user enter, add to brain if not already there
  # Give 50 credits just for coming by
  robot.enter (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    curr.userEnter user

  # On leave, mark user inactive, stop giving credits
  robot.leave (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    curr.userExit user

  # Give a user an arbitary number of credits
  robot.hear /^!give (\w+) (\d+)/i, (msg) ->
    if msg.envelope.user.name.toLowerCase() not in moderators
      msg.send("Nice try! Not going to happen though.")
    else
      user = msg.match[1].toLowerCase()
      amount = msg.match[2]
      curr.updateCredits user, amount
      msg.send "Gave #{user} #{amount} credits!"
 
  # User wants their balance
  robot.hear /^!balance/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    balance = curr.getBalance user
    msg.send "#{user}, your balance is #{balance}!"
  
  # Give all users credits!
  robot.hear /^!giveall (\d+)/i, (msg) ->
    amount = msg.match[1]
    curr.giveAll amount
    msg.send "Gave everyone #{amount} credits!"

  robot.hear /^!top$/i, (msg) ->
    resp = curr.checkTop()
    msg.send resp
