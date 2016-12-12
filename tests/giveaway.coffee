Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

giveawayHelper = new Helper('../scripts/giveaway.coffee')

describe 'count tests', ->
  beforeEach ->
    @room = giveawayHelper.createRoom()

  afterEach ->
    @room.destroy()

  context 'no giveaway in progress', ->
    it 'tries to start a giveaway as a normal user', ->
      @room.user.say('katie', '!giveaway a new car').then =>
        expect(@room.messages).to.eql [
          ['katie', '!giveaway a new car']
          ['hubot', 'You are not a moderator. You cannot authorize a giveaway!']
        ]
 
    it 'tries to enter a giveaway when one is not in progress', ->
      @room.user.say('katie', '!win').then =>
        expect(@room.messages).to.eql [
          ['katie', '!win']
          ['hubot', '@katie there is no giveaway in progress.']
        ]
 
    it 'tries to close a giveaway as a normal user', ->
      @room.user.say('katie', '!closeGiveaway').then =>
        expect(@room.messages).to.eql [
          ['katie', '!closeGiveaway']
          ['hubot', 'You are not a moderator. You cannot close a giveaway!']
        ]
 
    it 'tries to close a giveaway when one is not in progress', ->
      @room.user.say('alice', '!closeGiveaway').then =>
        expect(@room.messages).to.eql [
          ['alice', '!closeGiveaway']
          ['hubot', 'There is no giveaway in progress!']
        ]
 
  context 'no giveaway in progress', ->
    it 'opens a giveaway', ->
      @room.user.say('oscar', '!giveaway one brand new project scorpio').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!giveaway one brand new project scorpio']
          ['hubot', 'The giveaway has launched! Cough up 0 credits for a chance to win! Use !win to enter the drawing.']
        ]
 
    it 'fails to open a second giveaway', ->
      @room.user.say('alice', '!giveaway some books').then =>
        expect(@room.messages).to.eql [
          ['alice', '!giveaway some books']
          ['hubot', 'A giveaway is already in progress. Use !checkGiveaway for details']
        ]
 
    it 'enters the giveaway as a mod', ->
      @room.user.say('alice', '!win').then =>
        expect(@room.messages).to.eql [
          ['alice', '!win']
          ['hubot', '@alice moderators cannot enter the giveaway. You\'re already special!']
        ]
 
    it 'enters the giveaway', ->
      @room.user.say('glen', '!win').then =>
        expect(@room.messages).to.eql [
          ['glen', '!win']
          ['hubot', '@glen you are in for the giveaway. Your remaining balance is 0 and you can attempt an additional 9 times.']
        ]
 
    it 'fails to enter the giveaway with negative number', ->
      @room.user.say('katie', '!win -6').then =>
        expect(@room.messages).to.eql [
          ['katie', '!win -6']
        ]
 
    it 'enters the giveaway too many times', ->
      @room.user.say('glen', '!win 20').then =>
        expect(@room.messages).to.eql [
          ['glen', '!win 20']
          ['hubot', '@glen you have entered the maximum allowed entries.']
        ]
 
    it 'enters the giveaway max times', ->
      @room.user.say('glen', '!win 9').then =>
        expect(@room.messages).to.eql [
          ['glen', '!win 9']
          ['hubot', '@glen you are in for the giveaway. Your remaining balance is 0 and you can attempt an additional 0 times.']
        ]
 
    it 'closes the giveaway as a mod', ->
      @room.user.say('alice', '!closeGiveaway').then =>
        expect(@room.messages).to.eql [
          ['alice', '!closeGiveaway']
          ['hubot', 'The giveaway is closed! We will now tally the entries']
          ['hubot', 'And the winner is........']
          ['hubot', 'glen! Please whisper one of alice,oscar to claim your prize!']
        ]
 
