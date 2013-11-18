events = require 'events'

class SocketIOAdapter extends events.EventEmitter
  constructor: (opts = {}) ->
    @serverManager = opts.serverManager
    @io = opts.io

  start: ->
    @_bindManagerEvents()
    @io.sockets.on 'connection', @_bindSocketEvents

  sendServerList: (socket) =>
    socket.emit 'servers:list-received', @serverManager.getWorldNames()

  sendServerStatus: (serverName, socket) =>
    target = socket || @io.sockets
    statusCode = @serverManager.getServerStatusCode(serverName)

    target.emit 'server:status-updated', serverName, statusCode

  sendUserList: (serverName, _user) =>
    users = @serverManager.getServer(serverName)?.getUsers()
    @io.sockets.emit 'server:user-list-updated', serverName, users

  sendServerData: (type, serverName, data) ->
    @io.sockets.emit "server:#{type}", serverName, data

  startServer: (serverName) =>
    @serverManager.launchWorld(serverName)

  stopServer: (serverName) =>
    @serverManager.getServer(serverName)?.kill()

  sendServerCommand: (serverName, data) =>
    @serverManager.getServer(serverName)?.write(data + "\n")

  _bindManagerEvents: ->
    # Logging Events
    for type in ['stdout', 'stderr']
      @serverManager.on "server:#{type}", (serverName, data) =>
        @sendServerData(type, serverName, data)

    # Server Status Events
    @serverManager.on 'server:pending', @sendServerStatus
    @serverManager.on 'server:started', @sendServerStatus
    @serverManager.on 'server:stopped', @sendServerStatus

    # Server User Events
    @serverManager.on 'server:user-joined', @sendUserList
    @serverManager.on 'server:user-left', @sendUserList

  _bindSocketEvents: (socket) =>
    socket.on 'servers:list', => 
      @sendServerList(socket)

    socket.on 'server:get-status', (serverName) =>
      @sendServerStatus(serverName, socket)

    socket.on 'server:get-users', @sendUserList
    socket.on 'server:start', @startServer
    socket.on 'server:stop', @stopServer
    socket.on 'server:send-command', @sendServerCommand

module.exports = SocketIOAdapter