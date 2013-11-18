events = require 'events'

class Server extends events.EventEmitter
  constructor: (name, process) ->
    @name = name
    @started = false
    @_users = []

    @_process = process
    @_setEncoding()
    @_setDefaultBindings()

  kill: ->
    @_process.kill()
    @emit 'stopped'

  write: (data) ->
    if data
      @_process.stdin.write(data)

  getUsers: ->
    return @_users

  _setEncoding: ->
    @_process.stdout.setEncoding 'utf8'
    @_process.stderr.setEncoding 'utf8'

  _setDefaultBindings: ->
    @_process.on 'exit', =>
      @emit 'stopped'

    @_process.stdout.on 'data', (data) =>
      if data
        @_parseLine(data)
        @emit 'stdout:dataEmitted', data

    @_process.stderr.on 'data', (data) =>
      if data
        @emit 'stderr:dataEmitted', data

  _parseLine: (line) ->
    # Server has started
    if !@started && /Done (.*?)For help/.test(line)
      @started = true
      @emit 'started'
      return

    # User joined the game
    if match = /\: (.*?) joined the game/.exec(line)
      if username = match[1]
        @_users.push(username)
        @emit 'user-joined', username
      
      return

    # User left the game
    if match = /\: (.*?) left the game/.exec(line)
      if username = match[1]
        @_users.splice(@_users.indexOf(username), 1)
        @emit 'user-left', username

      return

module.exports = Server