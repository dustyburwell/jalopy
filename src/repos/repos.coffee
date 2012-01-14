
class Repositories
  constructor: () -> 
    return 

  enableMock: () ->
    @api = require './mockdir'

  list: (args...) -> 
    this.get_api().list(args...)

  add: (owner, name, callback) ->
    this.get_api().add owner, name
    callback()

  get_api: () ->
    @api ||= require './dir'

module.exports = new Repositories()