Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

callResponseHelper = new Helper('../scripts/quote.coffee')

describe 'quote tests', ->
  beforeEach ->
    @room = callResponseHelper.createRoom()

  afterEach ->
    @room.destroy()

  it 'does not allow non-admin add', ->
    @room.user.say('drew', '!quote add foobie blech').then =>
      expect(@room.messages).to.eql [
        ['drew', '!quote add foobie blech']
        ['hubot', 'I\'m sorry, I can\'t let you do that.']
      ]

  context 'admin adds a quote', ->
    it 'allows admin add', ->
      @room.user.say('alice', '!quote add foobie blech').then =>
        expect(@room.messages).to.eql [
          ['alice', '!quote add foobie blech']
          ['hubot', 'Added quote. Quote count at 1']
        ]

    # Doesn't work. Likely due to brain save delays
    #it 'should have one quote in the brain', ->
    #  expect(@room.robot.brain.get 'quotes').to.eql ['foobie blech']

  context 'user asks for a quote', ->
    beforeEach ->
      @room.robot.brain.set 'quotes', ['foobie blech']

    it 'retrieves a quote', ->
      @room.user.say('bob', '!quote random').then =>
        expect(@room.messages).to.eql [
          ['bob', '!quote random']
          ['hubot', 'foobie blech']
        ]
