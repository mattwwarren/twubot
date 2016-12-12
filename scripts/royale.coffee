# Description:
#   
# 
# Configuration:
#
# Notes:
#

robotBrain = require '../lib/brain'
randomize = require '../lib/randomize'

HUBOT_ROYALE_SIZE = process.env.HUBOT_ROYALE_SIZE || 4
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []
DEFAULT_CHALLENGER_COUNT = process.env.HUBOT_DEFAULT_CHALLENGER_COUNT || 1
moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS

class Royale
  constructor: (@robot) ->
    @brain = new robotBrain.BrainSingleton.get @robot
    @royale = @brain.get('royale') ? 'unready'
    @challengers = @brain.get('royale_challengers') ? []
    @champions = @brain.get('royale_champions') ? []
   
  openRoyale: (user) -> 
    if user not in moderators
      return "#{user} you are not allowed to start a battle royale!"
    else if @royale == 'open' or @royale == 'ready' or @royale == 'inprogress'
      return 'There is already a Battle Royale open! You have to !closeRoyale before you can open another!'
    else
      @royale = 'open'
      @champions = HUBOT_TWITCH_OWNERS
      @challengers = []
      @brain.set 'royale', @royale
      @brain.set 'royale_challengers', @challengers
      @brain.set 'royale_champions', @champions

      return "The Battle Royale has begun! Use !checkroyale to see the queue and !joinroyale to challenge #{@champions}"

  checkRoyale: () ->
    if @royale == 'unready'
      return 'There is no battle in progress. Are you asking for a challenge?!'
    else if @royale == 'open'
      challengerstext = ""
      if @challengers.length > 0
        challengerstext = " with #{@challengers}"
      return "You still have time to join in the fight#{challengerstext} against #{@champions}"
    else
      return "Current champions #{@champions} are facing off against #{@challengers.join(', ')}"

  joinRoyale: (user) ->
    if @royale == 'unready'
      return "Don't get too eager, #{user}. There's no battle right now but you'll have your day."
    else
      if user in @challengers
        return 'You are only allowed one entry. Good spirit though.'
      else
        @challengers.push user
        @brain.set 'royale_challengers', @challengers
        return "You're in for the battle. Prepare yourself."

  leaveRoyale: (user) ->
    if @royale == 'unready'
      return "There is no battle in progress right now."
    else
      if user in @challengers
        newchallengers = (u for u in @challengers when u != user)
        @challengers = newchallengers
        @brain.set 'royale_challengers', newchallengers
        return "#{user} has exited the battle."
      else
        return "#{user} was never in the battle. Shrug."

  kickRoyale: (kicker, kickee) ->
    if kicker not in moderators
      return "#{kicker} you are not allowed to kick anyone from the battle!"
    else
      return @leaveRoyale kickee

  mixRoyaleRotation: (user) ->
    if user not in moderators
      return "#{user} you are not allowed to mix up a battle royale!"
    else if @royale == 'inprogress'
      @challengers = randomize.randomize @challengers
      @brain.set 'royale_challengers', @challengers
      return 'Challenger order has been randomized!'
    else
      return 'The battle has not started yet. Use !startRoyale before randomizing the order.'

  startRoyale: (user, rotationSize) ->
    if user not in moderators
      return "#{user} you are not allowed to start a battle royale!"
    else if @royale == 'open'
      firstChallengers = @pickChallengers(rotationSize)
      if typeof firstChallengers is 'number'
        return "There are not enough challengers for your battle! Change the default or use !nextChallengers with fewer than #{firstChallengers}."
      else
        @royale = 'inprogress'
        @brain.set 'royale', @royale
        resp = "First pick of challengers: #{firstChallengers}. When the challenge has ended, use !nextChallengers"
        return resp
     else
       return 'Battle Royale is not open or ready to start!'

  pickChallengers: (num) =>
    i = 0
    resp = []
    if num > @challengers.length
      return @challengers.length
    else
      while ++i <= num
        challenger = @challengers.shift()
        resp.push challenger
        @challengers.push challenger
      return resp.join ', '

  nextChallengers: (user, challengerCount) ->
    if @royale == 'inprogress'
      nextChallengers = @pickChallengers(challengerCount)
      if typeof nextChallengers is 'number'
        return "There are not enough challengers for your battle! Change the default or use !nextChallengers with #{nextChallengers} or fewer."
      else
      resp = "Next up: #{nextChallengers}. When the challenge has ended, use !nextChallengers"
    else
      return 'The battle has not started yet. Use !startRoyale before changing challengers'

  closeRoyale: (user) ->
    if user not in moderators
      return "#{user} you are not allowed to end the battle royale!"
    else if @royale == 'unready' 
      return "The Battle Royale has already closed. Open a new one with !openroyale."
    else
      @royale = 'unready'
      @challengers = []
      @brain.set 'royale', @royale
      @brain.set 'royale_challengers', @challengers

      return "The Battle Royale is over! Thank you to all who participated!"

module.exports = (robot) ->
  royale = new Royale robot

  robot.hear /^!openroyale/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    resp = royale.openRoyale user
    msg.send resp

  robot.hear /^!joinroyale/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    resp = royale.joinRoyale user
    msg.send resp

  robot.hear /^!nextChallengers?( \d+)?/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    challengerCount = parseInt((msg.match[1] ? " " + DEFAULT_CHALLENGER_COUNT).trim())
    resp = royale.nextChallengers user, challengerCount
    msg.send resp

  robot.hear /^!startroyale( \d+)?/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    challengerCount = parseInt((msg.match[1] ? " " + DEFAULT_CHALLENGER_COUNT).trim())
    resp = royale.startRoyale user, challengerCount
    msg.send resp

  robot.hear /^!closeroyale/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    resp = royale.closeRoyale user
    msg.send resp

  robot.hear /^!leaveRoyale/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    resp = royale.leaveRoyale user
    msg.send resp
  
  robot.hear /^!kickRoyale (\w+)/i, (msg) ->
    kicker = msg.envelope.user.name.toLowerCase()
    kickee = msg.match[1]
    resp = royale.kickRoyale kicker, kickee
    msg.send resp
  
  robot.hear /^!mixRoyale/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    resp = royale.mixRoyaleRotation user
    msg.send resp
  
  robot.hear /^!checkroyale/i, (msg) ->
    resp = royale.checkRoyale()
    msg.send resp
