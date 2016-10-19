# Description:
#   Occasionally reminds people in chat to do things
#   Also allows for adding of reminders
# 
# Notes:
#   Configure reminder interval with HUBOT_REMINDER_INTERVAL
#
# Usage:
#   !addReminder Something something something follow, like, subscribe.
#

{EventEmitter} = require 'events'
REMINDER_TIMEOUT = (process.env.HUBOT_REMINDER_INTERVAL ? 2) * 60 * 1000
ROOM = process.env.HUBOT_TWITCH_CHANNELS
remindEvents = new EventEmitter

class Reminders
  constructor: (@robot) ->
    @reminders = []
    
    @robot.brain.on 'loaded', =>
      if @robot.brain.data
        @reminders = @robot.brain.get 'reminders'

  getReminder: () ->
    if @reminders.length > 0
      item = @reminders[Math.floor(Math.random()*@reminders.length)]

  remindHumans: () ->
    reminder = @getReminder()
    remindEvents.emit 'messageRoom', ROOM, reminder

  addReminder: (reminder) ->
    @reminders.push reminder
    @robot.brain.set 'reminders', @reminders
    return 'Reminder added!'

module.exports = (robot) ->
  reminders = new Reminders robot

  setTimeout ( ->
    reminders.remindHumans()
  ), REMINDER_TIMEOUT

  robot.hear /^!addReminder (.*)$/i, (msg) ->
    reminder = msg.match[1]
    resp = reminders.addReminder reminder
    msg.send resp

  remindEvents.on 'messageRoom', (room = "", message = "") ->
    robot.messageRoom room, message
