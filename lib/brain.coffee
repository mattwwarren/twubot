root = exports ? this

class SimpleBrain
  constructor: (@robot) -> 
    @cache = {}
    @robot.brain.on 'loaded', =>
      if @robot.brain.data
        @cache = @robot.brain.data

  set: (key, value) ->
    @cache[key] = value

  get: (key) ->
    return @cache[key]

class BrainSingleton
  instance = null
  
  @get: (robot) ->
    instance ?= new SimpleBrain(robot)

root.BrainSingleton = BrainSingleton
