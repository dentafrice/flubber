class window.App
  start: ->
    @_setupSocket()
    @_fireInitialEvents()

    @model = new Backbone.Model(name: 'main', statusCode: -2, users: [], logMessages: []) # server
    @serverView = new Flubber.ServerView(model: @model, socket: @socket)
    @serverView.render()
    $('#server_list').append(@serverView.el)

  onServerDisconnected: =>
    console.log 'Server disconnected'

  onServerResponse: (serverName, data) =>
    @model.get('logMessages').push(data)
    @model.trigger 'logMessage:add', data

  onServerStatusUpdate: (serverName, statusCode) =>
    @model.set('statusCode', statusCode)

  onUserListUpdate: (serverName, users) =>
    @model.set('users', users || [])

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

  _fireInitialEvents: ->
    @socket.emit('servers:list')
    @socket.emit('server:get-status', 'main')
    @socket.emit('server:get-users', 'main')