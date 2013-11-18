express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
ServerManager = require './src/server_manager'
SocketIOAdapter = require './src/socket_io_adapter'
worlds = require './config/worlds'

# Setup Servers
io.set('log level', 1)
server.listen(8080)

app.use express.static(__dirname + '/build/public')

app.get '/', (req, res) ->
  res.sendfile __dirname + '/build/index.html'

# Setup Server Manager
manager = new ServerManager(worlds: worlds)

# Shut down all of the server processes in when this process exits.
process.on 'exit', ->
  manager.shutdown()

process.on 'SIGTERM', ->
  process.exit()

socketAdapter = new SocketIOAdapter(serverManager: manager, io: io)
socketAdapter.start()