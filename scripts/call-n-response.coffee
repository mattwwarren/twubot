
fs = require 'fs'
data_file = fs.readFileSync 'data/call-n-response.json'
data = JSON.parse(data_file)

module.exports = (robot) ->
  keys_regex = new RegExp("!(" + Object.keys(data).join("|") + ")", "i")
  robot.hear keys_regex, (res) ->
    console.log res.match
    res.send data[res.match[1]]
