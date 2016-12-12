Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

reminderHelper = new Helper('../scripts/reminders.coffee')

describe 'reminder tests', ->
  beforeEach ->
    @room = reminderHelper.createRoom()

  afterEach ->
    @room.destroy()

  context 'creating reminders', ->
    it 'add a reminder', ->
      @room.user.say('oscar', '!addReminder this test is a little silly').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!addReminder this test is a little silly']
          ['hubot', 'Reminder added!']
        ]
 
    it 'add a reminder as a user', ->
      @room.user.say('drew', '!addReminder I am hacking the system').then =>
        expect(@room.messages).to.eql [
          ['drew', '!addReminder I am hacking the system']
          ['hubot', 'Sorry, you are not allowed to add reminders']
        ]
 
