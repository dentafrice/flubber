proc = require 'child_process'
Server = require './server'

class ServerManager
  constructor: (opts = {}) ->
    @worlds = opts.worlds
    @_servers = {}

  launchWorld: (worldName) ->
    serverData = @worlds[worldName]

    unless serverData
      throw "World (#{worldName}) not found"

    # Spin up world
    console.log ">> Launching world: #{worldName}"
    serverProcess = proc.spawn 'java', ["-Xms#{serverData.minRam}M", "-Xmx#{serverData.maxRam}M", '-jar', serverData.serverFile, 'nogui'], cwd: serverData.directory    

    server = new Server(worldName, serverProcess)
    @_servers[worldName] = server

    return server

  getServer: (worldName) ->
    @_servers[worldName]

  shutdown: ->
    console.log ">> Killing all servers"
    for name, server of @_servers
      server.kill()

module.exports = ServerManager