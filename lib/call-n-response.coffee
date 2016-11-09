MAX_COMMANDS = process.env.HUBOT_MAX_COMMAND_LIST ? 20

class exports.CallNResponse
  constructor: (@robot) -> 
    @cnr = {}
    @callRegex = ""

    @robot.brain.on 'loaded', =>
      if @robot.brain.data
        @cnr = @robot.brain.get 'call-n-response'
        @callRegex = new RegExp("^!(" + Object.keys(@cnr).join("|") + ")", "i")

  addResponse: (call, response) ->
    @cnr[call] = response
    @robot.brain.set 'call-n-response', @cnr
    return "Added command: " + call

  getResponse: (call) ->
    return @cnr[call]

  getAllResponses: ->
    resp = "Available commands: "
    totalCommands = 0
    for command in Object.keys(@cnr)                             
      totalCommands += 1
      if totalCommands == 1
        resp = resp + command
      else 
        resp = resp + ", " + command                                 
    if totalCommands > MAX_COMMANDS
       return "Oh my, there are #{totalCommands} in the system! " +
              "There's no way I could list them all!"
    else
       return resp

