fs    = require 'fs'
path  = require 'path'
async = require 'async'

class RepositoryDirectory
  constructor: () ->
    return

  list: (args..., callback) ->

    options = 
      base: process.env['JALOPY_GIT_DIRECTORY']

    listOwnerRepositories = (owner, callback) ->
      fs.readdir path.join(options.base, owner), (err, repos) ->
        if err
          callback err, null
        else
          callback null, (path.join(owner, repo) for repo in repos)

    owner = if args.length then args.shift() else null

    if owner
      listOwnerRepositories owner, (err, repos) -> 
        callback repos
    else
      fs.readdir options.base, (err, owners) ->
        async.map owners
        , listOwnerRepositories
        , (err, owners) ->
          callback [].concat owners...

module.exports = new RepositoryDirectory()