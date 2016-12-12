_ = require 'underscore'

HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []
moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS

class exports.Currency
  constructor: (@robot) ->
    @creds = {}

    @robot.brain.on 'loaded', =>
      if @robot.brain.data
        @creds = @robot.brain.get('credits') ? {}
      else
        @robot.brain.set 'credits', @creds

  createUser: (user) ->
    checkUser = user.toLowerCase()
    if checkUser not in Object.keys(@creds)
      @creds[checkUser] = {}
      balance = @creds[checkUser]['bank'] ? 0
      balance = parseInt(balance)
      @creds[checkUser]['bank'] = balance

    @robot.brain.set 'credits', @creds

  # Function to give everyone the appropriate amount of credits
  earnCredits: (credits) ->
    for user in Object.keys(@creds)
      if @creds[user]['active'] == 'true'
        balance = @creds[user]['bank'] ? 0
        balance = parseInt(balance)
        balance += parseInt(credits)
        @creds[user]['bank'] = balance

    @robot.brain.set 'credits', @creds

  userEnter: (user) ->
    now = new Date().getTime()
    if user not in Object.keys(@creds)
      @createUser user
      balance = parseInt(@creds[user]['bank'])
      balance += 50
      @creds[user]['bank'] = balance
    @creds[user]['lastJoined'] = now
    @creds[user]['active'] = 'true'
    if not @creds[user]['firstJoined']?
      @creds[user]['firstJoined'] = now

    @robot.brain.set 'credits', @creds

  userExit: (user) ->
    if user in Object.keys(@creds)
      @creds[user]['active'] = 'false'
    
    @robot.brain.set 'credits', @creds
      
  payCredits: (user, credits) ->
    if user not in Object.keys(@creds)
      @createUser user
    balance = @creds[user]['bank'] ? 0
    balance = parseInt(balance)
    if balance >= credits
      balance -= parseInt(credits)
      @creds[user]['bank'] = balance
      @robot.brain.set 'credits', @creds
      return balance
    else
      return -1

  updateCredits: (user, credits) ->
    if user not in Object.keys(@creds)
      @createUser user
    balance = @creds[user]['bank'] ? 0
    balance = parseInt(balance)
    balance += parseInt(credits)
    @creds[user]['bank'] = balance

    @robot.brain.set 'credits', @creds

  getBalance: (user) ->
    wagers = @robot.brain.get('hack_wagers') or {}
    if user not in Object.keys(@creds)
      @createUser user
    balance = @creds[user]['bank'] ? 0
    if user in Object.keys(wagers)
      wager = wagers[user]
      balance = balance + "[-#{wager}]"
    return balance

  giveAll: (user, amount) ->
    if user.toLowerCase() not in moderators
      return "Nice try! Not going to happen though."
    else
      for user in Object.keys(@creds)
        if @creds[user]['active'] == 'true'
          balance = @creds[user]['bank'] ? 0
          balance = parseInt(balance)
          balance += parseInt(amount)
          @creds[user]['bank'] = balance
    
      @robot.brain.set 'credits', @creds
      return "Gave everyone #{amount} credits!"

  checkTop: ->
    balances = []
    for user in Object.keys(@creds)
      checkedBalance = {}
      checkedBalance['user'] = user
      checkedBalance['balance'] = @getBalance user
      balances.push(checkedBalance)
    rankedBalances = _.sortBy balances, 'balance'
    top10 = rankedBalances.reverse().slice(0,10)
    resp = "||"
    for topUser in top10
      resp = resp + " " + topUser['user'] + ": " + topUser['balance'] + " |"
    resp = resp + "|"
    return resp
