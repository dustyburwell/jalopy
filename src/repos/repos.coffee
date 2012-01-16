
class Repositories
  constructor: () -> 
    return 

  enableMock: () ->
    @api = require './mockdir'

  disableMock: () ->
    @api = null

  list: (args...) -> 
    @get_api().list(args...)

  add: (owner, name, callback) ->
    @get_api().add owner, name, callback

  get_api: () ->
    @api ?= require './dir'

module.exports = new Repositories()