# Class to handle viewers, viewer data and viewer analytics
#

robotBrain = require './brain'
TwitchApi = require 'twitch-api'
moment = require 'moment'
class exports.Viewership
  constructor: (@robot, @channel) ->
    @brain = new robotBrain.BrainSingleton.get @robot
    @users = @brain.getUsers() ? {}
    @streams = @brain.get('streams') ? []
    twapiParams = {'clientId': process.env.HUBOT_TWITCH_CLIENT_ID}
    twapiParams['clientSecret'] = process.env.HUBOT_TWITCH_CLIENT_SECRET
    twapiParams['redirectUri'] = process.env.HUBOT_TWITCH_REDIRECT_URI
    twapiParams['scopes'] = ['user_read', 'channel_read']

    @twapi = new TwitchApi twapiParams

  userEnter: (user) ->
    now = new Date().getTime()
    @users[user]['lastJoined'] = now
    @users[user]['here'] = true
    if not @users[user]['firstJoined']?
      @users[user]['firstJoined'] = now
    @checkFollows user, (followp) =>
      if followp
        @users[user]['followDate'] = followp.calendar()
    @brain.setUsers @users

  userExit: (user) ->
    now = new Date().getTime()
    @users[user]['here'] = false
    @users[user]['lastPart'] = now
    @checkFollows user, (followp) =>
      if followp
        @users[user]['followDate'] = followp.calendar()
    @brain.setUsers @users

  getLastSeen: (user) ->
    now = new Date().getTime()
    if user in Object.keys(@users)
      present = @users[user]['here']
      lastSeen = moment(@users[user]['lastPart'], "x").calendar()
      if present
        return "#{user} is here!"
      else
        return "#{user} last seen on #{lastSeen}"
    else
      return "Sorry, I don't know #{user}"

  checkTime: (user) ->
    # this is empty because we have to track stream live time first
    return false

  checkFollows: (user, callback) ->
    # Track total followers and reconcile against internal user data
    @twapi.getUserFollowsChannel user, @channel, (error, resp) ->
      if not error 
        followDate = moment(resp['created_at'], 'YYYY-MM-DDTHH:mm:ssZ')
        callback followDate
      else if error.status == 404
        callback false
      else
        console.log error

  setCustomGreeting: (user, greeting) ->
    if @users[user]
      @users[user]['greeting'] = greeting
      return true
    else
      return false
    @brain.setUsers @users
    
  getCustomGreeting: (user) ->
    if @users[user]
      return @users[user]['greeting'] || false
    else
      return false
    
