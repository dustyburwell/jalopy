sys  = require 'sys'
{ Git, RawGit, NiceGit } = require 'treeeater-dustyburwell'
util = require 'util'
proc = require('child_process')
fs   = require('fs')
path = require('path')

is_git_repo = (dir, callback) ->
  proc.exec "git rev-parse", { cwd: dir } , (error, stdout, stderr) ->
    callback error is null

module.exports = (app) -> 

  app.get '/repositories/new', (req, res) ->
    res.render 'repos/new', { error: req.flash('error'), info: req.flash('info') }

  app.post '/repositories/new', (req, res) ->
    repo = require('./repos')

    owner = req.body.repository.owner
    name  = req.body.repository.name
    desc  = req.body.repository.desc

    repo.add owner, name, (err) ->
      if err
        req.flash 'error', err
        res.redirect 'back'
      else
        req.flash 'info', 'New repository created'
        res.redirect 'home'

  app.get '/:path([\\w\\W]+)/compare/:old...:new', (req, res) ->
    repo_dir = "/Users/dusty/Workspace/#{req.params.path}"

    is_git_repo repo_dir, (is_git) ->
      if is_git
        git = new Git cwd: repo_dir
        git.diffs "#{req.params.old}..#{req.params.new}", (diffs) ->
          res.render 'repos/compare', { 
            repo: req.params.path,
            a:    req.params.old,
            b:    req.params.new,
            out:  diffs
          }, 
      else
        res.render 'repos/notfound', repo: req.params.path

  app.get '/:owner', (req, res, next) ->
    repo = require('./repos')
    path = req.params.owner

    repo.list path, (err, list) ->
      if err
        console.log "error while listing repositories #{err}"
        next()
      else
        res.render 'repos/ownerRepos', { 
          path:  path,
          repos: list
        }

  app.get '/', (req, res) ->
    repo = require('./repos')
    
    repo.list (err, list) ->
      console.log "error while listing repositories #{err}" if err
        
      res.render 'repos/index', { 
        repos: list
      }