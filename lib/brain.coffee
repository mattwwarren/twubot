root = exports ? this

class SimpleBrain
  constructor: (@robot) -> 
    @cache = {}
    @users = {}
    @robot.brain.on 'loaded', =>
      if @robot.brain.data
        @cache = @robot.brain.data
        @users = @robot.brain.users()

  set: (key, value) ->
    @cache[key] = value

  get: (key) ->
    return @cache[key]

  setUsers: (users) ->
    @users = users

  getUsers: () ->
    return @users

class BrainSingleton
  instance = null
  
  @get: (robot) ->
    instance ?= new SimpleBrain(robot)

root.BrainSingleton = BrainSingleton
