# Description:
#   Manages shop inventory and sales
# 
# Notes:
#
# Usage:
#   !addinventory {item} {cost} {defaultStock}
#   !addstock {item} {number}
#   !purchase {item}
#   !sell {item}
#

SELL_DIVISOR = process.env.HUBOT_INVENTORY_SELL_DIVISOR ? 2
DEFAULT_STOCK = process.env.HUBOT_INVENTORY_DEFAULT_STOCK ? 20
DEFAULT_MAX_ITEM_COUNT = process.env.HUBOT_INVENTORY_COUNT_DEFAULT_MAX ? 5
DEFAULT_MAX_ITEMS = process.env.HUBOT_INVENTORY_DEFAULT_MAX ? 5
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []

currency = require '../lib/currency'
robotBrain = require '../lib/brain'
moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS

class Inventory
  constructor: (@robot) ->
    @curr = new currency.Currency @robot
    @brain = new robotBrain.BrainSingleton.get robot
    @store = @brain.get('store') ? {}
    @users = @brain.getUsers()


  addInventory: (user, item, cost, stock = DEFAULT_STOCK) =>
    if user not in moderators
      return "Sorry #{user} you can't add to the store"
    if item not of @store
      @store[item] = {} 
      @store[item]['stock'] = stock
      @store[item]['cost'] = cost
      @brain.set 'store', @store
      return "#{stock} #{item} added to the store for #{cost} credits each"
    else
      return item + " already in store and cannot be overwritten."

  addStock: (user, item, stock = DEFAULT_STOCK) =>
    if user not in moderators
      return "Sorry #{user} you can't add stock"
    if item not of @store
      return "#{item} does not seem to be in the store. Do you want to !addinventory?"
    else
      @store[item]['stock'] += stock
      @brain.set 'store', @store
      newstock = @store[item]['stock']
      return "A flash delivery of #{item} has arrived. There are #{newstock} now available"

  getStoreInventory: () =>
    resp = "Current inventory: "
    if @store and Object.keys(@store).length > 0
      for item of @store
        resp += "#{@store[item]['stock']} #{item} at #{@store[item]['cost']} each."
    else
      resp = "empty?! Did someone steal everything? Tell #{HUBOT_TWITCH_OWNERS} to stock it up!"
    return resp

  addToUserInventory: (user, item) =>
    currentInv = 0
    if @users[user]['inventory']
      if @users[user]['inventory'][item] < DEFAULT_MAX_ITEM_COUNT and Object.keys(@users[user]['inventory']).length < DEFAULT_MAX_ITEMS
        @users[user]['inventory'][item] += 1
        @brain.setUsers @users
        currentInv = @users[user]['inventory'][item]
      else
        currentInv = -1
    else
      @users[user]['inventory'] = {}
      @users[user]['inventory'][item] = 1
      @brain.setUsers @users
      currentInv = @users[user]['inventory'][item]
    return currentInv

  subtractUserInventory: (user, item) =>
    currentInv = -1
    if @users[user]['inventory'] and @users[user]['inventory'][item] > 1
      @users[user]['inventory'][item] -= 1
      @brain.setUsers @users
      currentInv = @users[user]['inventory'][item]
    return currentInv

  getUserInventory: (user) =>
    resp = "your current inventory: "
    if @users[user]['inventory'] and Object.keys(@users[user]['inventory']).length > 0
      for item of @users[user]['inventory']
        resp += "#{@users[user]['inventory'][item]} #{item}"
    else
      resp += "empty."
    return resp

  purchaseItem: (user, item) =>
    if item not of @store
      return "Sorry, we're fresh out of #{item} right now. Beg #{HUBOT_TWITCH_OWNERS} to add some!"
    else
      cost = @store[item]['cost']
      payment = @curr.payCredits user, cost

      if payment < 0
        return "Sorry, you don't have enough credits to purchase #{item}" +
               " Join in !bankhack or hang around to earn more"
      else
        if @store[item]['stock'] > 1
          @store[item]['stock'] -= 1
          userStock = @addToUserInventory(user, item)
          if userStock > 0
            return "you are the proud new owner of #{userStock} #{item}! Put it to good use!"
          else
            return "you have the max allowed stock of #{item}! Use them or !sell them back."
        else
          return "the stop is current out of #{item}! Pester #{HUBOT_TWITCH_OWNERS} to stock up!"

  sellItem: (user, item, stock) =>
    if item not of @store
      return "Sorry, you can't sell back something not in current inventory. That's priceless!"
    else
      userStock = @subtractUserInventory(user, item, stock)
      if userStock >= 0
        purchasePrice = @store[item]['cost'] / SELL_DIVISOR
        gains = @curr.updateCredits user, purchasePrice
        @store[item]['stock'] += stock
        return "Thank you for doing business with the shop."
      else
        return "You don't have #{stock} of #{item} to sell"

  discardItem: (user, item, stock) =>
    userStock = @subtractUserInventory(user, item, stock)
    if userStock >= 0
      return "#{user} carelessly throws #{stock} #{item} aside. Next time why not !sell it back?"
    else
      return "You don't have #{stock} of #{item} to toss."

module.exports = (robot) ->
  inventory = new Inventory robot

  robot.hear /!addinventory (\w+) (\d+)( \d+)?/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    item = msg.match[1]
    cost = msg.match[2]
    stock = msg.match[3] ? DEFAULT_STOCK
    resp = inventory.addInventory(user, item, cost, stock)
    msg.send resp
  
  robot.hear /!addstock (\w+)( \d+)?/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    item = msg.match[1]
    stock = msg.match[2] ? DEFAULT_STOCK
    resp = inventory.addStock(user, item, stock)
    msg.send resp

  robot.hear /!purchase (\w+)/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    item = msg.match[1]
    resp = inventory.purchaseItem(user, item)
    msg.reply resp

  robot.hear /!store/i, (msg) ->
    resp = inventory.getStoreInventory()
    msg.send resp

  robot.hear /!inventory/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    resp = inventory.getUserInventory(user)
    msg.reply resp

  robot.hear /!sell (\w+)( \d+)/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    item = msg.match[1]
    stock = msg.match[2] ? 1
    resp = inventory.sellItem(user, item, stock)
    msg.send resp

  robot.hear /!discard (\w+)( \d+)/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    item = msg.match[1]
    stock = msg.match[2] ? 1
    resp = inventory.discardItem(user, item, stock)
    msg.send resp
