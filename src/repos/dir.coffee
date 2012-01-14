fs    = require 'fs'
path  = require 'path'
async = require 'async'

class RepositoryDirectory
  constructor: () ->
    return

  list: (args..., callback) ->
    #owner = if args.length then args.shift() else null
    base = process.env['JALOPY_GIT_DIRECTORY']

    fs.readdir base, (err, owners) ->
      async.map owners
      , (owner, callback) -> 
        fs.readdir path.join(base, owner), (err, repos) ->
          if err
            callback err, null
          else
            callback null, path.join(owner, repo) for repo in repos
      , (err, owners) ->
        callback (owner for owner in owners)

    ###if owner?
      (repo for repo in @repos when repo.indexOf(owner) == 0).sort()
    else
      @repos.sort()
    ###

module.exports = new RepositoryDirectory()