net = require('net')

Q = require('q')
_ = require('underscore')

class Client
  constructor: (@options) ->
    unless @options.port and @options.host
      throw "You must provide a port and host"

  open: ->
    if not @openPromise? or @openPromise.promise.isRejected()
      @openPromise = Q.defer()

      opts = _.pick @options, 'host', 'port'
      opts.port = +opts.port

      @client = net.connect opts

      @client.on 'connect', =>
        @openPromise.resolve @client

      @client.on 'error', (err) =>
        console.error err, 'on socket'

        if @openPromise?.promise.isPending()
          @openPromise = null

      @client.on 'close', =>
        @openPromise = null

    @openPromise.promise

  send: (data) ->
    send = (client) =>
      now = Math.floor(+new Date / 1000)
      rows = []

      for item in data
        tagString = ""
        if item.tags?
          tagString = _(item.tags).pairs().map((pair) -> pair.join('=')).join(' ')

        rows.push "put #{ item.key } #{ now } #{ item.val } #{ tagString }"

      client.write rows.join('\n') + '\n'
      
    if not @openPromise? or @openPromise.promise.isRejected()
      @open().then send
    else
      send(@client)

module.exports = Client
