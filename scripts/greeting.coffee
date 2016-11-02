# Description:
#   Track viewer first joins, follows, and last seen
# 
# Configuration:
#
# Notes:
#

channel = process.env.HUBOT_TWITCH_CHANNELS.substr(1)
GREETING_PRICE = process.env.HUBOT_CUSTOM_GREETING_PRICE ? 20000
viewership = require '../lib/viewership'
currency = require '../lib/currency'

module.exports = (robot) ->
  viewers = new viewership.Viewership robot, channel
  curr = new currency.Currency robot

  robot.enter (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    greeting = viewers.getCustomGreeting user
    if greeting
      msg.send greeting

  robot.hear /^!buyGreeting (.*)/i,(msg) ->
    greeting = msg.match[1]
    user = msg.envelope.user.name.toLowerCase()
    balance = curr.payCredits user, GREETING_PRICE
    if balance >= 0
      greetingp = viewers.setCustomGreeting user, greeting
      if greetingp
        msg.reply "Your custom greeting is set!" +
                  " Next time you join, we will greet you!"
      else
        msg.reply "I'm sorry, I can't seem to find your user." +
                  " Please try again in a few minutes"
    else
      msg.reply "You don't have enough credits to buy a custom greeting " +
                "right now. Wait until you have at least #{GREETING_PRICE} credits!"
