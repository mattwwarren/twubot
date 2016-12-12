Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

greetingHelper = new Helper('../scripts/greeting.coffee')

describe 'greeting tests', ->
  beforeEach ->
    @room = greetingHelper.createRoom()

  afterEach ->
    @room.destroy()

  context 'greet all the things', ->
    it 'tries to buy a greeting', ->
      @room.user.say('katie', '!buyGreeting hello ya fools').then =>
        expect(@room.messages).to.eql [
          ['katie', '!buyGreeting hello ya fools']
          ['hubot', '@katie you don\'t have enough credits to buy ' +
                    'a custom greeting right now. Wait until you ' +
                    'have at least 20000 credits!']
        ]
 
