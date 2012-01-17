fs    = require 'fs'
path  = require 'path'
async = require 'async'

class RepositoryDirectory
  constructor: () ->
    return

  listOwnerRepositories: (owner, callback) =>
    options = @options()

    fs.readdir path.join(options.base, owner), (err, repos) ->
      if err
        callback err, null
      else
        callback null, (path.join(owner, repo) for repo in repos)

  list: (args..., callback) =>
    owner = if args.length then args.shift() else null

    if owner
      path.exists path.join(@options().base, owner), (exists) =>
        if exists 
          @listOwnerRepositories owner, (err, repos) -> 
            console.log "Repos for #{owner}: #{repos}"
            callback err, repos
        else
          callback new Error('No owner')
    else
      fs.readdir @options().base, (err, owners) =>
        async.map owners
        , @listOwnerRepositories
        , (err, owners) ->
          callback err, [].concat owners...

  add: (owner, repository, callback) =>
    Git = require('treeeater-dustyburwell').Git

    path.exists path.join(@options().base, owner), (exists) =>
      if not exists
        callback('The owner directory does not exist')
      else
        path.exists path.join(path.join(@options().base, owner), repository), (exists) =>
          if exists
            callback('The repository already exists')
          else
            git = new Git cwd: (path.join @options().base, owner)
            git.init '--bare', "#{repository}", (out) ->
              callback(null)

  options: () =>
    @_options ||= 
      base: process.env['JALOPY_GIT_DIRECTORY']

module.exports = new RepositoryDirectory()