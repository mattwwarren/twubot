Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

royaleHelper = new Helper('../scripts/royale.coffee')

describe 'inventory tests', ->
  beforeEach ->
    @room = royaleHelper.createRoom()

  afterEach ->
    @room.destroy()

  it 'checks for a battle where none exist', ->
    @room.user.say('drew', '!checkRoyale').then =>
      expect(@room.messages).to.eql [
        ['drew', '!checkRoyale']
        ['hubot', 'There is no battle in progress. Are you asking for a challenge?!']
      ]

  it 'joins a battle that does not exist', ->
    @room.user.say('drew', '!joinroyale').then =>
      expect(@room.messages).to.eql [
        ['drew', '!joinroyale']
        ['hubot', 'Don\'t get too eager, drew. There\'s no battle right now but you\'ll have your day.']
      ]

  it 'leaves a battle that does not exist', ->
    @room.user.say('drew', '!leaveroyale').then =>
      expect(@room.messages).to.eql [
        ['drew', '!leaveroyale']
        ['hubot', 'There is no battle in progress right now.']
      ]

  it 'starts a battle that does not exist', ->
    @room.user.say('alice', '!startroyale').then =>
      expect(@room.messages).to.eql [
        ['alice', '!startroyale']
        ['hubot', 'Battle Royale is not open or ready to start!']
      ]

  it 'kicks from a battle that does not exist', ->
    @room.user.say('alice', '!kickroyale drew').then =>
      expect(@room.messages).to.eql [
        ['alice', '!kickroyale drew']
        ['hubot', 'There is no battle in progress right now.']
      ]

    it 'tries to mix up the rotation', ->
      @room.user.say('alice', '!mixroyale').then =>
        expect(@room.messages).to.eql [
          ['alice', '!mixroyale']
          ['hubot', 'The battle has not started yet. use !startRoyale before randomizing the order.']
        ]
  
  context 'starts a battle and users join', ->
    it 'starts the battle royale', ->
      @room.user.say('oscar', '!openroyale').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!openroyale']
          ['hubot', 'The Battle Royale has begun! Use !checkroyale to see the queue and !joinroyale to challenge oscar']
        ]
  
    it 'tries to start a second battle', ->
      @room.user.say('oscar', '!openroyale').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!openroyale']
          ['hubot', 'There is already a Battle Royale open! You have to !closeRoyale before you can open another!']
        ]
  
    it 'tries to start a battle as a regular user', ->
      @room.user.say('glen', '!openroyale').then =>
        expect(@room.messages).to.eql [
          ['glen', '!openroyale']
          ['hubot', 'glen you are not allowed to start a battle royale!']
        ]
  
    it 'checks the status of the battle', ->
      @room.user.say('glen', '!checkRoyale').then =>
        expect(@room.messages).to.eql [
          ['glen', '!checkRoyale']
          ['hubot', 'You still have time to join in the fight against oscar']
        ]
  
    it 'starts the battle', ->
      @room.user.say('alice', '!startroyale').then =>
        expect(@room.messages).to.eql [
          ['alice', '!startroyale']
          ['hubot', 'There are not enough challengers for your battle! Change the default or use !nextChallengers with fewer than 0.']
        ]
  
    it 'joins the battle', ->
      @room.user.say('glen', '!joinroyale').then =>
        expect(@room.messages).to.eql [
          ['glen', '!joinroyale']
          ['hubot', 'You\'re in for the battle. Prepare yourself.']
        ]
  
    it 'tries to join the battle second time', ->
      @room.user.say('glen', '!joinroyale').then =>
        expect(@room.messages).to.eql [
          ['glen', '!joinroyale']
          ['hubot', 'You are only allowed one entry. Good spirit though.']
        ]
  
    it 'tries to mix the rotation', ->
      @room.user.say('alice', '!mixroyale').then =>
        expect(@room.messages).to.eql [
          ['alice', '!mixroyale']
          ['hubot', 'The battle has not started yet. Use !startRoyale before randomizing the order.']
        ]
  
    it 'tries to next the rotation', ->
      @room.user.say('alice', '!nextchallenger').then =>
        expect(@room.messages).to.eql [
          ['alice', '!nextchallenger']
          ['hubot', 'The battle has not started yet. Use !startRoyale before changing challengers']
        ]
  
    it 'starts the battle', ->
      @room.user.say('alice', '!startroyale').then =>
        expect(@room.messages).to.eql [
          ['alice', '!startroyale']
          ['hubot', 'First pick of challengers: glen. When the challenge has ended, use !nextChallengers']
        ]
  
    it 'moves to the next 10 in the rotation', ->
      @room.user.say('alice', '!nextchallengers 10').then =>
        expect(@room.messages).to.eql [
          ['alice', '!nextchallengers 10']
          ['hubot', 'There are not enough challengers for your battle! Change the default or use !nextChallengers with 1 or fewer.']
        ]
  
    it 'moves to the next in the rotation', ->
      @room.user.say('oscar', '!nextchallenger').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!nextchallenger']
          ['hubot', 'Next up: glen. When the challenge has ended, use !nextChallengers']
        ]
  
    it 'joins a second user to the battle', ->
      @room.user.say('alice', '!joinroyale').then =>
        expect(@room.messages).to.eql [
          ['alice', '!joinroyale']
          ['hubot', 'You\'re in for the battle. Prepare yourself.']
        ]
  
    it 'checks the battle status', ->
      @room.user.say('drew', '!checkroyale').then =>
        expect(@room.messages).to.eql [
          ['drew', '!checkroyale']
          ['hubot', 'Current champions oscar are facing off against glen, alice']
        ]
  
    it 'mixes up the rotation', ->
      @room.user.say('alice', '!mixroyale').then =>
        expect(@room.messages).to.eql [
          ['alice', '!mixroyale']
          ['hubot', 'Challenger order has been randomized!']
        ]
  
    it 'tries to kick a user from a battle', ->
      @room.user.say('drew', '!kickroyale glen').then =>
        expect(@room.messages).to.eql [
          ['drew', '!kickroyale glen']
          ['hubot', 'drew you are not allowed to kick anyone from the battle!']
        ]

    it 'kicks non-joined user from a battle', ->
      @room.user.say('alice', '!kickroyale drew').then =>
        expect(@room.messages).to.eql [
          ['alice', '!kickroyale drew']
          ['hubot', 'drew was never in the battle. Shrug.']
        ]

    it 'kicks from a battle that does not exist', ->
      @room.user.say('alice', '!kickroyale glen').then =>
        expect(@room.messages).to.eql [
          ['alice', '!kickroyale glen']
          ['hubot', 'glen has exited the battle.']
        ]

    it 'leaves the battle', ->
      @room.user.say('alice', '!leaveroyale').then =>
        expect(@room.messages).to.eql [
          ['alice', '!leaveroyale']
          ['hubot', 'alice has exited the battle.']
        ]

    it 'closes the battle as a non mod', ->
      @room.user.say('drew', '!closeroyale').then =>
        expect(@room.messages).to.eql [
          ['drew', '!closeroyale']
          ['hubot', 'drew you are not allowed to end the battle royale!']
        ]
  
    it 'closes the battle', ->
      @room.user.say('alice', '!closeroyale').then =>
        expect(@room.messages).to.eql [
          ['alice', '!closeroyale']
          ['hubot', 'The Battle Royale is over! Thank you to all who participated!']
        ]
  
    it 'tries to close the battle again', ->
      @room.user.say('alice', '!closeroyale').then =>
        expect(@room.messages).to.eql [
          ['alice', '!closeroyale']
          ['hubot', 'The Battle Royale has already closed. Open a new one with !openroyale.']
        ]
  
