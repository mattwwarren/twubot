Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

rankHelper = new Helper('../scripts/rank.coffee')

describe 'rank tests', ->
  beforeEach ->
    @room = rankHelper.createRoom()

  afterEach ->
    @room.destroy()

  context 'creating and joining ranks', ->
    it 'lists empty ranks', ->
      @room.user.say('glen', '!listranks').then =>
        expect(@room.messages).to.eql [
          ['glen', '!listranks']
          ['hubot', 'Available ranks: none! Add one with !addrank']
        ]
 
    it 'tries to add a rank as a regular user', ->
      @room.user.say('glen', '!addrank 1000 thousandaire').then =>
        expect(@room.messages).to.eql [
          ['glen', '!addrank 1000 thousandaire']
          ['hubot', '@glen no can do. You\'re not an admin.']
        ]
 
    it 'tries to add a rank as a mod', ->
      @room.user.say('alice', '!addrank 0 free loaders').then =>
        expect(@room.messages).to.eql [
          ['alice', '!addrank 0 free loaders']
          ['hubot', 'free loaders is now available as a rank. Pay up 0 credits to join']
        ]
 
    it 'tries to add the same rank', ->
      @room.user.say('oscar', '!addrank 0 free loaders').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!addrank 0 free loaders']
          ['hubot', 'Sorry, free loaders already exists as a rank']
        ]
 
    it 'tries to add a rank with cost', ->
      @room.user.say('oscar', '!addrank 1000000 high rollers').then =>
        expect(@room.messages).to.eql [
          ['oscar', '!addrank 1000000 high rollers']
          ['hubot', 'high rollers is now available as a rank. Pay up 1000000 credits to join']
        ]
 
    it 'joins the free rank', ->
      @room.user.say('glen', '!joinrank free loaders').then =>
        expect(@room.messages).to.eql [
          ['glen', '!joinrank free loaders']
          ['hubot', '@glen you are now a member of free loaders!']
        ]
 
    it 'fails to join the expensive rank', ->
      @room.user.say('glen', '!joinrank high rollers').then =>
        expect(@room.messages).to.eql [
          ['glen', '!joinrank high rollers']
          ['hubot', '@glen Sorry, you don\'t have enough credits to join high rollers. You need 1000000.']
        ]
 
    it 'joins the free rank again', ->
      @room.user.say('glen', '!joinrank free loaders').then =>
        expect(@room.messages).to.eql [
          ['glen', '!joinrank free loaders']
          ['hubot', '@glen um, you\'re already in free loaders']
        ]
 
    it 'tries to join a non-existent rank', ->
      @room.user.say('glen', '!joinrank not a rank').then =>
        expect(@room.messages).to.eql [
          ['glen', '!joinrank not a rank']
          ['hubot', '@glen Sorry, not a rank is not a valid rank. Check ranks with !listranks']
        ]
 
    it 'lists ranks', ->
      @room.user.say('glen', '!listranks').then =>
        expect(@room.messages).to.eql [
          ['glen', '!listranks']
          ['hubot', 'Available ranks: free loaders: 0, high rollers: 1000000']
        ]
 
    it 'checks ranks', ->
      @room.user.say('drew', '!checkrank glen').then =>
        expect(@room.messages).to.eql [
          ['drew', '!checkrank glen']
          ['hubot', 'glen is a member of free loaders']
        ]
 
    it 'checks ranks', ->
      @room.user.say('drew', '!checkrank').then =>
        expect(@room.messages).to.eql [
          ['drew', '!checkrank']
          ['hubot', 'drew is not a member of any rank!']
        ]
 
    it 'leaves the free rank', ->
      @room.user.say('glen', '!leaverank free loaders').then =>
        expect(@room.messages).to.eql [
          ['glen', '!leaverank free loaders']
          ['hubot', '@glen you are no longer a member of free loaders!']
        ]
 
    it 'tries to leave a rank', ->
      @room.user.say('drew', '!leaverank high rollers').then =>
        expect(@room.messages).to.eql [
          ['drew', '!leaverank high rollers']
          ['hubot', '@drew um, you\'re not in high rollers']
        ]
 
    it 'tries to leave a non-existant rank', ->
      @room.user.say('drew', '!leaverank myrank').then =>
        expect(@room.messages).to.eql [
          ['drew', '!leaverank myrank']
          ['hubot', '@drew Sorry, myrank is not a valid rank. Check ranks with !listranks']
        ]
 
    it 'checks ranks', ->
      @room.user.say('drew', '!checkrank glen').then =>
        expect(@room.messages).to.eql [
          ['drew', '!checkrank glen']
          ['hubot', 'glen is not a member of any rank!']
        ]
 
