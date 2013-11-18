class window.App
  start: ->
    @_setupSocket()
    @_servers = {}

    # harcoded for now
    # needs to use the list from the server
    @_createInitialServer()

  onServerDisconnected: =>
    console.log '>> Server disconnected'
    @socket.once 'connect', =>
      console.log '>> Server connected'
      @_createInitialServer()

  onServerResponse: (serverName, data) =>
    view = @_servers[serverName]
    view.model.get('logMessages').push(data)
    view.model.trigger 'logMessage:add', data

  onServerStatusUpdate: (serverName, statusCode) =>
    view = @_servers[serverName]
    view.model.set('statusCode', statusCode)

  onUserListUpdate: (serverName, users) =>
    view = @_servers[serverName]
    view.model.set('users', users || [])

  _setupSocket: ->
    @socket = io.connect('http://localhost')
    @socket.on 'disconnect', @onServerDisconnected
    @_setupSocketBindings()

  _setupSocketBindings: ->
    @socket.on('server:stdout', @onServerResponse)
    @socket.on('server:stderr', @onServerResponse)
    @socket.on('server:status-updated', @onServerStatusUpdate)
    @socket.on('server:user-list-updated', @onUserListUpdate)
    @socket.on('server:received-users', @onUserListUpdate)

  _createInitialServer: ->
    if @_servers['main']
      @_servers['main'].close()
      delete @_servers['main']

    model = new Flubber.Models.Server(name: 'main')
    serverView = new Flubber.ServerView(model: model, socket: @socket)
    $('#server_list').append(serverView.render().el)
    
    @_servers['main'] = serverView

    @socket.emit('server:get-status', 'main')
    @socket.emit('server:get-users', 'main')