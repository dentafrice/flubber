window.Flubber ?= {}
window.Flubber.Models ?= {}

class Flubber.Models.Server extends Backbone.Model
  defaults: ->
    statusCode: -2
    users: []
    logMessages: []
    isLogging: true

  getPrettyName: ->
    name = @get('name')
    return name.charAt(0).toUpperCase() + name.slice(1)

  getStatusText: ->
    switch @get('statusCode')
      when -1
        status = "Offline"

      when 0
        status = "Starting"

      when 1
        status = "Started"

      else
        status = "Loading..."

    return status