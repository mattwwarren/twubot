Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../scripts')
callResponseHelper = new Helper('../scripts/call-n-response.coffee')

describe 'call and response tests', ->
  beforeEach ->
    @room = callResponseHelper.createRoom()

  afterEach ->
    @room.destroy()

  it 'lists an empty command list', ->
    @room.user.say('alice', '!commandlist').then =>
      expect(@room.messages).to.eql [
        ['alice', '!commandlist']
        ['hubot', 'Available commands: ']
      ]

  context 'add responses', ->
    it 'tries to add a response as a normal user', ->
      @room.user.say('katie', '!learn hello what is up son?').then =>
        expect(@room.messages).to.eql [
          ['katie', '!learn hello what is up son?']
          ['hubot', 'I\'m sorry, I can\'t let you do that.']
        ]

    it 'tries to add a response as a moderator', ->
      @room.user.say('alice', '!learn hello what is up son?').then =>
        expect(@room.messages).to.eql [
          ['alice', '!learn hello what is up son?']
          ['hubot', 'Added command: hello']
        ]

    it 'responds with the new command', ->
      @room.user.say('katie', '!hello').then =>
        expect(@room.messages).to.eql [
          ['katie', '!hello']
          ['hubot', 'what is up son?']
        ]

    it 'lists one command in the list', ->
      @room.user.say('katie', '!commandlist').then =>
        expect(@room.messages).to.eql [
          ['katie', '!commandlist']
          ['hubot', 'Available commands: hello']
        ]

    it 'adds 20 commands', ->
      for i in [0...20] by 1
        @room.user.say('alice', "!learn example#{i} response#{i}").then =>
          expect(@room.messages).to.eql [
            ['alice', '!learn example#{i} response#{i}']
            ['hubot', 'Added command: example#{i}']
          ]

    it 'will not list all commands due to length', ->
      @room.user.say('katie', '!commandlist').then =>
        expect(@room.messages).to.eql [
          ['katie', '!commandlist']
          ['hubot', 'Oh my, there are 21 commands in the system! There\'s no way I could list them all!']
        ]

    it 'respond to an example command', ->
      @room.user.say('katie', '!example5').then =>
        expect(@room.messages).to.eql [
          ['katie', '!example5']
          ['hubot', 'response5']
        ]

