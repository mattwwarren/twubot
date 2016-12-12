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
REMINDER_TIMEOUT = process.env.HUBOT_REMINDER_INTERVAL ? 10
ROOM = process.env.HUBOT_TWITCH_CHANNELS
HUBOT_TWITCH_ADMINS = process.env.HUBOT_TWITCH_ADMINS?.split "," || []
HUBOT_TWITCH_OWNERS = process.env.HUBOT_TWITCH_OWNERS?.split "," || []

remindEvents = new EventEmitter
robotBrain = require '../lib/brain'

class Reminders
  constructor: (@robot) ->
    @brain = new robotBrain.BrainSingleton.get @robot
    @reminders = @brain.get('reminders') ? []
    
  getReminder: () ->
    if @reminders.length > 0
      item = @reminders[Math.floor(Math.random()*@reminders.length)]
      return item

  remindHumans: () ->
    reminder = @getReminder()
    remindEvents.emit 'messageRoom', ROOM, reminder

  addReminder: (reminder) ->
    @reminders.push reminder
    @brain.set 'reminders', @reminders
    return 'Reminder added!'

module.exports = (robot) ->
  cronJob = require('cron').CronJob
  reminders = new Reminders robot
  moderators = HUBOT_TWITCH_ADMINS.concat HUBOT_TWITCH_OWNERS

  # Remind humans on each interval
  new cronJob("0 */#{REMINDER_TIMEOUT} * * * *", reminders.remindHumans, null, true)

  robot.hear /^!addReminder (.*)$/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    reminder = msg.match[1]
    if user in moderators
      resp = reminders.addReminder reminder
    else
      resp = 'Sorry, you are not allowed to add reminders'
    msg.send resp

  remindEvents.on 'messageRoom', (room = "", message = "") ->
    robot.messageRoom room, message
