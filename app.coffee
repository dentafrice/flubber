ServerManager = require './src/server_manager'
worlds = require './config/worlds'
io = require 'socket.io'
io.listen(8080)

# Create ServerManager
manager = new ServerManager(worlds: worlds)
mainServer = manager.launchWorld 'main'

# Setup Bindings
mainServer.on 'stdout:dataEmitted', (data) ->
  process.stdout.write ">> #{data}"

mainServer.on 'stderr:dataEmitted', ->
  process.stderr.write ">> #{data}"

# Allow us to send commands to the mainServer
process.stdin.setEncoding 'utf8'
process.stdin.resume()
process.stdin.on 'data', (data) ->
  if data
    mainServer.write(data)

# Shut down all of the server processes in when this process exits.
process.on 'exit', ->
  manager.shutdown()