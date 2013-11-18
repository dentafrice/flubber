proc = require 'child_process'

worlds =
  main:
    directory: 'worlds/main'
    serverFile: 'minecraft_server.1.7.2.jar'
    minRam: 1024
    maxRam: 1024

launchServer = (worldName) ->
  serverData = worlds[worldName]

  unless serverData
    throw "World (#{worldName}) not found"

  # Spin up world
  console.log ">> Launching world: #{worldName}"
  server = proc.spawn 'java', ["-Xms#{serverData.minRam}M", "-Xmx#{serverData.maxRam}M", '-jar', serverData.serverFile, 'nogui'], cwd: serverData.directory

  # Set encodings
  server.stdout.setEncoding 'utf8'
  server.stderr.setEncoding 'utf8'

  # Set bindings
  server.stdout.on 'data', (data) ->
    if data
      process.stdout.write ">> #{data}"

  server.stderr.on 'data', (data) ->
    if data
      process.stderr.write ">> #{data}"

  server.on 'exit', ->
    server = null

  return server

server = launchServer 'main'

process.stdin.setEncoding 'utf8'
process.stdin.resume()
process.stdin.on 'data', (data) ->
  if data
    server.stdin.write(data)