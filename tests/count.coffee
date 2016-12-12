Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

countHelper = new Helper('../scripts/count.coffee')

describe 'count tests', ->
  beforeEach ->
    @room = countHelper.createRoom()

  afterEach ->
    @room.destroy()

  context 'counting all the things', ->
    it 'tries to get all counts of none', ->
      @room.user.say('katie', '!counts').then =>
        expect(@room.messages).to.eql [
          ['katie', '!counts']
          ['hubot', 'Current events: Nothing. Nothing has happened. Ever.']
        ]
 
    it 'tries to count something that doesn\'t exist', ->
      @room.user.say('katie', '!checkCount foobie blech').then =>
        expect(@room.messages).to.eql [
          ['katie', '!checkCount foobie blech']
          ['hubot', 'foobie blech has not happened yet. Record it with !count']
        ]
  
    it 'counts a thing', ->
      @room.user.say('katie', '!count foobie blech').then =>
        expect(@room.messages).to.eql [
          ['katie', '!count foobie blech']
          ['hubot', 'foobie blech now at 1']
        ]
  
    it 'counts a thing again', ->
      @room.user.say('katie', '!count foobie blech').then =>
        expect(@room.messages).to.eql [
          ['katie', '!count foobie blech']
          ['hubot', 'foobie blech now at 2']
        ]
  
    it 'counts a different thing', ->
      @room.user.say('katie', '!count smaug').then =>
        expect(@room.messages).to.eql [
          ['katie', '!count smaug']
          ['hubot', 'smaug now at 1']
        ]

    it 'tries to get all counts', ->
      @room.user.say('katie', '!counts').then =>
        expect(@room.messages).to.eql [
          ['katie', '!counts']
          ['hubot', 'Current events: 2 foobie blech, 1 smaug']
        ]
 
    it 'gets a count', ->
      @room.user.say('katie', '!checkCount smaug').then =>
        expect(@room.messages).to.eql [
          ['katie', '!checkCount smaug']
          ['hubot', 'smaug has happened 1 times']
        ]

