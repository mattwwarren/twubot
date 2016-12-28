# Description:
#   Open a poll to viewers
# 
# Configuration:
#
# Notes:
#   Initial plan is to only allow binary responses
#
_ = require 'underscore'
VOTE_TIME = (process.env.HUBOT_VOTE_TIME ? 2) * 60 * 1000

class Votes
  constructor: (@robot) -> 
    @cache = {}
    @voting = {}

    @robot.brain.on 'loaded', =>
      if @robot.brain.data
        @cache = @robot.brain.data
      if @robot.brain.data.voting
        @voting = @robot.brain.data.voting

  pollReminder: (room, poll) ->
    choices = @voting.choices.join(', ')
    @robot.emit 'voteMessage', room, "Did you vote yet? The question is still " +
                               "open! Submit your answer with !vote {choice} " +
                               "with one of #{choices}. The question is: #{poll}"

  pollResults: (room, poll) ->
    voting = @voting
    results = @voting.responses
    allResults = ""
    # Need to reverse this but no internet on the flight
    rankedResults = _.sortBy _.keys(results), (result) ->
      results[result]
    winner = rankedResults.reverse()[0]
    if winner != rankedResults.reverse()[1]
      @robot.emit 'voteMessage', room, "It's all over! The winner is #{winner}!"
    else
      for result in _.keys(results)
        allResults = allResults + " #{result} had #{results[result]} votes"
      @robot.emit 'voteMessage', room, "It's a tie!" + allResults
    @voting["responses"] = {}
    @voting["votes"] = 0
    @voting["voters"] = []
    @voting["live"] = false
    @voting["current_vote"] = ""
    @voting["choices"] = []
    @robot.brain.set "voting", @voting
    @cache = @robot.brain.data

  setPoll: (poll, room, choices) ->
    @voting["responses"] = @generateResponses(choices)
    @voting["votes"] = 0
    @voting["voters"] = []
    @voting["live"] = true
    @voting["current_vote"] = poll
    @voting["choices"] = choices
    @cache["vote_#{poll}"] = @voting

    @robot.brain.set "voting", @voting
    @robot.brain.set "vote_#{poll}", @cache["vote_#{poll}"]

  generateResponses: (choices) ->
    responses = {}
    for choice in choices
      responses[choice] = 0
    return responses
      

  getLive: ->
    return @voting.live

  getVotes: ->
    return @voting.votes

  getVoters: ->
    return @voting.voters

  getChoices: ->
    return @voting.choices

  getCurrentVote: ->
    return @voting.current_vote

  getResponses: ->
    return @voting.responses

  getVoteInfo: (poll) ->
    return @cache["vote_#{poll}"]

  addVote: (user, answer) ->
    votes = @getVotes()
    live = @getLive()
    voters = @getVoters()
    if live
      if user in voters
        return "No, no, no #{user}. You already voted once."
      else
        poll = @getCurrentVote()
        choices = @getChoices()
        responses = @getResponses()
        if answer in choices
          responses[answer] += 1
          voters.push user
          votes += 1
          @voting["voters"] = voters
          @voting["votes"] = votes
          @voting["responses"] = responses
          vote_info = @getVoteInfo poll
          vote_info["votes"] = votes
          vote_info["voters"] = voters
          vote_info["responses"] = responses
          @cache["vote_#{poll}"] = vote_info
          @robot.brain.set "vote_#{poll}", vote_info
          @robot.brain.set "voting", @voting
          return "#{user} voted #{answer}"
        else
          return "Sorry #{user}, #{answer} is not a valid " +
                 "response for this poll."
    else
      return "There is no poll in progress. Keep an eye out for !vote"
    
module.exports = (robot) ->
  votes = new Votes robot

  robot.hear /^!vote (.*)( answers: )((.*)+(, (.*)+)*)?/i, (msg) ->
    poll = msg.match[1]
    answers = msg.match[2]
    if answers
      choices = msg.match[3].split(', ')
    else
      choices = [yes, no]
    room = msg.envelope.room
    live = votes.getLive()
    if choices.length > 1
      if live
        msg.send "Polls are already open! You can't have more than one poll!"
      else
        msg.send "Polling is open! Vote with !answer {choice} The question: #{poll} " +
               "Choices are #{choices}"
        votes.setPoll poll, room, choices
        setTimeout ( ->
          votes.pollReminder(room, poll)
        ), VOTE_TIME / 2

        setTimeout ( ->
          votes.pollResults(room, poll)
        ), VOTE_TIME
    else
      msg.send "Um, you can't have a poll with only one option. " +
               "What do you think this is? " + 
               "An American local town election?!"
    
  robot.hear /^!answer (.*)$/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    answer = msg.match[1]
    resp = votes.addVote user, answer
    msg.send resp

  robot.on 'voteMessage', (room = "", message = "") ->
    robot.messageRoom room, message
