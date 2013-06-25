net = require('net')

Q = require('q')
_ = require('underscore')

Unhapi = require('unhapi')('nopents:client')

class Client
  constructor: (@options) ->
    unless @options.port and @options.host
      throw "You must provide a port and host"

  open: ->
    unless @openPromise?
      @openPromise = Q.defer()

      opts = _.pick @options, 'host', 'port'
      opts.port = +opts.port

      client = net.connect opts

      client.on 'connect', =>
        @openPromise.resolve client

      client.on 'error', (err) =>
        Unhapi.error err, 'on socket'

        if @openPromise?.isPending()
          @openPromise.reject err

      client.on 'end', =>
        @openPromise = null

    @openPromise.promise

  send: (data) ->
    @open().then (client) =>
      now = Math.floor(+new Date / 1000)
      rows = []

      for key, desc of data
        [val, unit, sample] = @parseRow desc

        continue unless unit is 'ms'

        tags = {
          source: 'bucky'
        }
        tagString = _(tags).pairs().map((pair) -> pair.join('=')).join(' ')

        rows.push "put #{ key } #{ now } #{ val } #{ tagString }"

      client.write rows.join('\n') + '\n'

    @openPromise

  parseRow: (row) ->
    re = /([0-9\.]+)\|([a-z]+)(?:@([0-9\.]+))?/

    groups = re.exec(row)

    unless groups
      Unhapi.error "Unparsable row: #{ row }"
      return

    groups.slice(1, 4)

module.exports = Client
