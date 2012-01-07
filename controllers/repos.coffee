sys = require('sys')

module.exports = (app) -> 
  
  app.get '/:path([\\w\\W]+)/compare/:old...:new', (req, res) ->

    util  = require('util')
    exec  = require('child_process').exec

    cd = process.cwd()
    process.chdir("/Users/dusty/Workspace/#{req.params.path}")

    exec("git diff #{req.params.old} #{req.params.new}", (error, stdout, stderr) ->
      process.chdir(cd)

      res.render 'repos/compare', { 
        repo: req.params.path,
        a:    req.params.old,
        b:    req.params.new,
        out:  stdout,
        err:  stderr
      }
    )

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