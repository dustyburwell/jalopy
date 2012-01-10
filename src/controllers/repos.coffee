sys  = require 'sys'
{ Git, RawGit, NiceGit } = require 'treeeater'
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
    owner = req.body.repository.owner
    name = req.body.repository.name
    desc = req.body.repository.desc

    ownerdir = path.join('/Users/dusty/Workspace', owner)
    repodir = path.join(ownerdir, name)

    git = new Git { cwd: ownerdir }

    console.log ownerdir

    init_repo = () ->
      git.init "--bare", "#{name}", (out) ->
        req.flash 'info', 'New repository created'
        res.redirect 'home'

    fs.stat ownerdir, (err, stats) ->
      if err != null
        fs.mkdir ownerdir, 0755, (err) ->
          init_repo()
      else if stats.isDirectory()
        is_git_repo repodir, (is_repo) ->
          if is_repo
            req.flash 'error', 'The repository already exists'
            res.redirect 'back'
          else
            init_repo()
      else
        req.flash 'error', 'The owner directory cannot be created'
  
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

  app.get '/:path(*)?', (req, res) ->

    util  = require('util')
    exec  = require('child_process').exec

    cd = process.cwd()
    process.chdir("/Users/dusty/Workspace/")

    exec("find ./ -iname branches", (error, stdout, stderr) ->
      process.chdir(cd)

      res.render 'repos/index', { 
        repo: req.params.path,
        out:  stdout
      }
    )
