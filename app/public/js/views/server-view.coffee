window.Flubber ?= {}

class Flubber.ServerView extends Backbone.Marionette.ItemView
  template: 'server-view'
  className: 'server'

  modelEvents:
    'change:statusCode'     : 'onServerStatusChanged'
    'change:users'          : 'onUsersChange'
    'change:isLogging'      : 'onLoggingChanged'
    'logMessage:add'        : 'onLogMessageAdded'

  events:
    'click .clear-log'      : 'onClearLogClicked'
    'click .start-server'   : 'onStartServerClicked'
    'click .stop-server'    : 'onStopServerClicked'
    'submit .command-form'  : 'onCommandFormSubmitted'
    'change .logging'       : 'onLoggingCheckboxChanged'
 
  ui:
    log: 'ul.log'
    users: 'ul.users'

  serializeData: ->
    data = super
    data.name = @model.getPrettyName()
    data.statusText = @model.getStatusText()
    data

  initialize: (opts = {}) ->
    @socket = opts.socket

  enableStartButton: ->
    @$('.start-server').removeClass 'hidden'

  disableStartButton: ->
    @$('.start-server').addClass 'hidden'

  enableStopButton: ->
    @$('.stop-server').removeClass 'hidden'

  disableStopButton: ->
    @$('.stop-server').addClass 'hidden'

  onUsersChange: ->
    @_renderUsers()

  onLogMessageAdded: (message) ->
    return if not @model.get('isLogging')

    @ui.log.append($('<li>').text(message))

  onServerStarted: ->
    @enableStopButton()
    @disableStartButton()
    @$('.server-started').removeClass 'hidden'

  onServerPending: ->
    @disableStartButton()
    @disableStopButton()
    @$('.server-started').removeClass 'hidden'

  onServerStopped: ->
    @_clearLog()
    @_clearUsers()

    @enableStartButton()
    @disableStopButton()
    @$('.server-started').addClass 'hidden'

  onServerStatusChanged: ->
    @$('.server-status').text(@model.getStatusText())

    statusCode = @model.get('statusCode')

    # If the server just went offline we need to clear the users.
    if statusCode < 0
      @triggerMethod 'server:stopped'
    else if statusCode == 0
      @triggerMethod 'server:pending'
    else
      @triggerMethod 'server:started'

  onClearLogClicked: (e) ->
    e.preventDefault()
    @_clearLog()

  onStartServerClicked: (e) ->
    e.preventDefault()
    @socket.emit('server:start', @model.get('name'))

  onStopServerClicked: (e) ->
    e.preventDefault()
    @socket.emit('server:stop', @model.get('name'))

  onCommandFormSubmitted: (e) ->
    e.preventDefault()
    $command = @$('.command')

    return unless $command.val()

    @socket.emit('server:send-command', @model.get('name'), $command.val())

    $command.val('')

  onLoggingCheckboxChanged: (e) ->
    e.preventDefault()
    @model.set('isLogging', @$('.logging').is(':checked'))

  onLoggingChanged: ->
    if @model.get('isLogging')
      @$('.logging-area').removeClass 'hidden'
    else
      @$('.logging-area').addClass 'hidden'

  _clearLog: ->
    @model.set('logMessages', [])
    @ui.log.empty()

  _clearUsers: ->
    @model.set('users', [])
    @ui.users.empty()

  _renderUsers: ->
    @ui.users.empty()

    for user in @model.get('users')
      @ui.users.append($('<li>').text(user))