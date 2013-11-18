(function($, _, Backbone) {
  var App = function() {
    // Constructor
  };

  App.prototype.start = function() {
    this._setupSocket();
    this._setupDOMBindings();
    this._fireInitialEvents();
  };

  // Events
  App.prototype.onServerDisconnected = function() {
    console.log('Server disconnected');
  };

  App.prototype.onServerResponse = function(serverName, data) {
    $('#log').append($('<li>').text(data));
  };

  App.prototype.onServerStatusUpdate = function(serverName, statusCode) {
    var status;

    switch(statusCode) {
      case -1:
        status = "Offline";
        break;

      case 0:
        status = "Starting";
        break;

      case 1:
        status = "Started";
        break;
    }

    $('.server-status.' + serverName).text(status);
  };

  App.prototype.onUserListUpdate = function(serverName, users) {
    $('#users').empty();

    if(!users || users.length == 0) {
      return;
    }

    for(var i = 0; i < users.length; i++) {
      $('#users').append($('<li>').text(users[i]));
    }
  };

  // Setups
  App.prototype._setupSocket = function() {
    this.socket = io.connect('http://localhost');
    this.socket.on('disconnect', _.bind(this.onServerDisconnected, this));
    this._setupSocketBindings();
  };

  App.prototype._setupDOMBindings = function() {
    var _this = this;

    $('.clear-log').click(function(e) {
      e.preventDefault();
      $('#log').empty();
    });

    $("#command_form").submit(function(e) {
      e.preventDefault();

      _this.socket.emit('server:send-command', 'main', $('#command').val());

      $('#command').val('');
    });

    $('.start-server-link').click(function(e) {
      e.preventDefault();

      var $el = $(e.target);

      _this.socket.emit('server:start', $el.attr('data-server-name'));
    });

    $('.stop-server-link').click(function(e) {
      e.preventDefault();

      var $el = $(e.target);
      _this.socket.emit('server:stop', $el.attr('data-server-name'));
    });

    $('.get-users-link').click(function(e) {
      e.preventDefault();

      var $el = $(e.target);
      _this.socket.emit('server:get-users', $el.attr('data-server-name'));
    });
  };

  App.prototype._setupSocketBindings = function() {
    this.socket.on('server:stdout', _.bind(this.onServerResponse, this));
    this.socket.on('server:stderr', _.bind(this.onServerResponse, this));
    this.socket.on('server:status-updated', _.bind(this.onServerStatusUpdate, this));

    this.socket.on('server:user-list-updated', _.bind(this.onUserListUpdate, this));
    this.socket.on('server:received-users', _.bind(this.onUserListUpdate, this));
  };

  App.prototype._fireInitialEvents = function() {
    this.socket.emit('servers:list');
    this.socket.emit('server:get-status', 'main');
    this.socket.emit('server:get-users', 'main');
  };

  window.App = App;
})($, _, Backbone);