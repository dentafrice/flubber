events = require 'events'

class Server extends events.EventEmitter
  constructor: (name, process) ->
    @name = name

    @_process = process
    @_setEncoding()
    @_setDefaultBindings()

  kill: ->
    @emit 'killed'
    @_process.kill()

  write: (data) ->
    if data
      @_process.stdin.write(data)

  _setEncoding: ->
    @_process.stdout.setEncoding 'utf8'
    @_process.stderr.setEncoding 'utf8'

  _setDefaultBindings: ->
    @_process.on 'exit', =>
      @emit 'killed'

    @_process.stdout.on 'data', (data) =>
      if data
        @emit 'stdout:data', data

    @_process.stderr.on 'data', (data) =>
      if data
        @emit 'stderr:data', data

module.exports = Server