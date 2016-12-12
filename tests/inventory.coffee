Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

callResponseHelper = new Helper('../scripts/inventory.coffee')

describe 'inventory tests', ->
  beforeEach ->
    @room = callResponseHelper.createRoom()

  afterEach ->
    @room.destroy()

  it 'does not allow non-admin to add inventory', ->
    @room.user.say('drew', '!addinventory foo 2').then =>
      expect(@room.messages).to.eql [
        ['drew', '!addinventory foo 2']
        ['hubot', 'Sorry drew you can\'t add to the store']
      ]

  context 'attempts to add inventory', ->
    it 'does not allow stock to add non-existent items', ->
      @room.user.say('oscar', '!addstock foo 2').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!addstock foo 2']
          ['hubot', 'foo does not seem to be in the store. Do you want to !addinventory?']
        ]
  
    it 'does allow admins to add free items to inventory', ->
      @room.user.say('oscar', '!addinventory baz 0 8').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!addinventory baz 0 8']
          ['hubot', '8 baz added to the store for 0 credits each']
        ]

    it 'should have one inventory in the brain', ->
      @room.user.say('oscar', '!store').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!store']
          ['hubot', 'Current inventory: 8 baz at 0 each']
        ]

    it 'does allow admins to add to inventory', ->
      @room.user.say('oscar', '!addinventory foo 2').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!addinventory foo 2']
          ['hubot', '20 foo added to the store for 2 credits each']
        ]

    it 'does not allow admins to add to inventory twice', ->
      @room.user.say('oscar', '!addinventory foo 2').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!addinventory foo 2']
          ['hubot', 'foo already in store and cannot be overwritten.']
        ]

    it 'should have two inventory in the brain', ->
      @room.user.say('oscar', '!store').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!store']
          ['hubot', 'Current inventory: 8 baz at 0 each, 20 foo at 2 each']
        ]


  context 'attempts to add stock', ->
    it 'does not allow non-admin to add stock', ->
      @room.user.say('drew', '!addstock foo 2').then =>
        expect(@room.messages).to.eql [
          ['drew', '!addstock foo 2']
          ['hubot', 'Sorry drew you can\'t add stock']
        ]

    it 'does allow admins to add stock', ->
      @room.user.say('alice', '!addstock foo 2').then =>
        expect(@room.messages).to.eql [
          ['alice', '!addstock foo 2']
          ['hubot', 'A flash delivery of foo has arrived. There are 22 now available']
        ]

    it 'should have 22 stock in the inventory', ->
      @room.user.say('oscar', '!store').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!store']
          ['hubot', 'Current inventory: 8 baz at 0 each, 22 foo at 2 each']
        ]

  context 'attempts purchase and sale of items', ->
    it 'does not allow purchase of items not in stock', ->
      @room.user.say('drew', '!purchase bar').then =>
        expect(@room.messages).to.eql [
          ['drew', '!purchase bar']
          ['hubot', '@drew sorry, we\'re fresh out of bar right now. Beg oscar to add some!']
        ]

    it 'does not allow purchase without credits', ->
      @room.user.say('drew', '!purchase foo').then =>
        expect(@room.messages).to.eql [
          ['drew', '!purchase foo']
          ['hubot', '@drew sorry, you don\'t have enough credits to purchase foo. Join in !bankhack or hang around to earn more']
        ]

    it 'does allow purchase of free item', ->
      @room.user.say('glen', '!purchase baz').then =>
        expect(@room.messages).to.eql [
          ['glen', '!purchase baz']
          ['hubot', '@glen you are the proud owner of 1 baz! Put it to good use!']
        ]

    it 'should have 1 stock in the user inventory', ->
      @room.user.say('glen', '!inventory').then =>
        expect(@room.messages).to.eql [
          ['glen', '!inventory']
          ['hubot', '@glen your current inventory: 1 baz']
        ]

    it 'should have 0 stock in the alice inventory', ->
      @room.user.say('alice', '!inventory').then =>
        expect(@room.messages).to.eql [
          ['alice', '!inventory']
          ['hubot', '@alice your current inventory: empty.']
        ]

    it 'does not allow purchase of more items than in stock', ->
      @room.user.say('glen', '!purchase baz 12').then =>
        expect(@room.messages).to.eql [
          ['glen', '!purchase baz 12']
          ['hubot', '@glen the shop is currently out of baz! Pester oscar to stock up!']
        ]

    it 'does not allow purchase of more items than allowed', ->
      @room.user.say('glen', '!purchase baz 6').then =>
        expect(@room.messages).to.eql [
          ['glen', '!purchase baz 6']
          ['hubot', '@glen you have the max allowed stock of baz! Use them or !sell them back.']
        ]

    it 'does allow sale of one item', ->
      @room.user.say('glen', '!sell baz').then =>
        expect(@room.messages).to.eql [
          ['glen', '!sell baz']
          ['hubot', 'Thank you for doing business with the shop.']
        ]

    it 'does not allow sale of an item not in inventory', ->
      @room.user.say('glen', '!sell baz').then =>
        expect(@room.messages).to.eql [
          ['glen', '!sell baz']
          ['hubot', 'You don\'t have 1 of baz to sell']
        ]

    it 'should have 8 baz in the store', ->
      @room.user.say('oscar', '!store').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!store']
          ['hubot', 'Current inventory: 8 baz at 0 each, 22 foo at 2 each']
        ]

    it 'does not allow sale of an item not in store', ->
      @room.user.say('glen', '!sell foobar').then =>
        expect(@room.messages).to.eql [
          ['glen', '!sell foobar']
          ['hubot', 'Sorry, you can\'t sell back something not in current store inventory. That\'s priceless!']
        ]

    it 'does allow purchase of max item limit', ->
      @room.user.say('glen', '!purchase baz 5').then =>
        expect(@room.messages).to.eql [
          ['glen', '!purchase baz 5']
          ['hubot', '@glen you are the proud owner of 5 baz! Put it to good use!']
        ]

    it 'does not allow sale of more than in user inventory', ->
      @room.user.say('glen', '!sell baz 8').then =>
        expect(@room.messages).to.eql [
          ['glen', '!sell baz 8']
          ['hubot', 'You don\'t have 8 of baz to sell']
        ]

    it 'does not allow discard of more than in user inventory', ->
      @room.user.say('glen', '!discard baz 8').then =>
        expect(@room.messages).to.eql [
          ['glen', '!discard baz 8']
          ['hubot', 'You don\'t have 8 of baz to toss.']
        ]

    it 'does allow discard of one item', ->
      @room.user.say('glen', '!discard baz').then =>
        expect(@room.messages).to.eql [
          ['glen', '!discard baz']
          ['hubot', 'glen carelessly throws 1 baz aside. Next time why not !sell it back?']
        ]

    it 'should have 4 stock in the glen inventory', ->
      @room.user.say('glen', '!inventory').then =>
        expect(@room.messages).to.eql [
          ['glen', '!inventory']
          ['hubot', '@glen your current inventory: 4 baz']
        ]

    it 'does allow discard of total user inventory', ->
      @room.user.say('glen', '!discard baz 4').then =>
        expect(@room.messages).to.eql [
          ['glen', '!discard baz 4']
          ['hubot', 'glen carelessly throws 4 baz aside. Next time why not !sell it back?']
        ]

    it 'should have 0 stock in the glen inventory', ->
      @room.user.say('glen', '!inventory').then =>
        expect(@room.messages).to.eql [
          ['glen', '!inventory']
          ['hubot', '@glen your current inventory: empty.']
        ]

