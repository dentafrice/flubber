proc = require 'child_process'
Server = require './server'
events = require 'events'

class ServerManager extends events.EventEmitter
  constructor: (opts = {}) ->
    @worlds = opts.worlds
    @_servers = {}

  launchWorld: (serverName) ->
    serverData = @worlds[serverName]

    unless serverData
      throw "World (#{serverName}) not found"

    if @_servers[serverName]
      throw "Server already started"
      return

    # Spin up world
    serverProcess = proc.spawn 'java', ["-Xms#{serverData.minRam}M", "-Xmx#{serverData.maxRam}M", '-jar', serverData.serverFile, 'nogui'], cwd: serverData.directory    
    server = new Server(serverName, serverProcess)
    
    @_servers[serverName] = server
    
    @emit 'server:pending', serverName

    @_setupBindings(serverName)

    return server

  getWorldNames: ->
    names = []

    for name, _obj of @worlds
      names.push(name)
      
    return names

  getServer: (serverName) ->
    @_servers[serverName]

  getServerStatusCode: (serverName) ->
    if server = @getServer(serverName)
      if server.started
        return 1
      else
        return 0 # it's there but starting
    else
      return -1

  shutdown: ->
    console.log ">> Killing all servers"
    for name, server of @_servers
      server.kill()

  _setupBindings: (serverName) ->
    server = @_servers[serverName]

    server.on 'stdout:dataEmitted', (data) =>
      @emit 'server:stdout', serverName, data

    server.on 'stderr:dataEmitted', (data) =>
      @emit 'server:stderr', serverName, data

    server.on 'user-joined', (username) =>
      @emit 'server:user-joined', serverName, username

    server.on 'user-left', (username) =>
      @emit 'server:user-left', serverName, username

    server.once 'started', =>
      @emit 'server:started', serverName

    server.once 'stopped', =>
      delete @_servers[serverName]
      @emit 'server:stopped', serverName

module.exports = ServerManager