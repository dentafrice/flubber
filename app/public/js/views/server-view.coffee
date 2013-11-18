window.Flubber ?= {}

class Flubber.ServerView extends Backbone.Marionette.ItemView
  template: 'server-view'
  className: 'server'

  modelEvents:
    'change:statusCode'     : 'onServerStatusChanged'
    'change:users'          : 'onUsersChange'
    'logMessage:add'        : 'onLogMessageAdded'

  events:
    'click .clear-log'      : 'onClearLogClicked'
    'click .start-server'   : 'onStartServerClicked'
    'click .stop-server'    : 'onStopServerClicked'
    'submit .command-form'  : 'onCommandFormSubmitted'

  ui:
    log: 'ul.log'
    users: 'ul.users'

  initialize: (opts = {}) ->
    @socket = opts.socket

  getStatusText: ->
    switch @model.get('statusCode')
      when -1
        status = "Offline"

      when 0
        status = "Starting"

      when 1
        status = "Started"

      else
        status = "Loading..."

    return status

  serializeData: ->
    data = super
    data.name = data.name.charAt(0).toUpperCase() + data.name.slice(1)
    data.statusText = @getStatusText()
    data

  onUsersChange: ->
    @_renderUsers()

  onLogMessageAdded: (message) ->
    @ui.log.append($('<li>').text(message))

  onServerStatusChanged: ->
    @$('.server-status').text(@getStatusText())

    if @model.get('statusCode') < 0
      @model.set('users', [])

  onClearLogClicked: (e) ->
    e.preventDefault()
    @model.set('logMessages', [])
    @ui.log.empty()

  onStartServerClicked: (e) ->
    e.preventDefault()
    @socket.emit('server:start', @model.get('name'))

  onStopServerClicked: (e) ->
    e.preventDefault()
    @socket.emit('server:stop', @model.get('name'))

  onCommandFormSubmitted: (e) ->
    e.preventDefault()
    $command = @$('.command')

    @socket.emit('server:send-command', @model.get('name'), $command.val())

    $command.val('')

  _renderUsers: ->
    @ui.users.empty()

    for user in @model.get('users')
      @ui.users.append($('<li>').text(user))