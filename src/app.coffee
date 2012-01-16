#!/usr/bin/env node

express = require 'express'
sys     = require 'sys'
app     = express.createServer()

port    = process.env.PORT || 3000

process.env['JALOPY_GIT_DIRECTORY'] ||= '/git'

app.configure 'development', () ->
  app.use(express.logger({ format: ':method :url' }))
  app.use(express.static(__dirname + '/public'))
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', () -> 
  oneYear = 31557600000
  app.use(express.static(__dirname + '/public', { maxAge: oneYear }))
  app.use(express.errorHandler())

app.use express.cookieParser()
app.use express.session secret: "keyboard cat";
app.use express.bodyParser()

app.dynamicHelpers
  base: -> 
    return if '/' == app.route then '' else app.route 

app.error (err, req, res, next) ->
  if err instanceof NotFound
    res.render '404.jade', { 
      locals: 
        title : '404 - Not Found'
        description: ''
        author: ''
        analyticssiteid: 'XXXXXXX' 
      status: 404 
    }
  else
    res.render '500.jade', { 
      locals: 
        title : 'The Server Encountered an Error'
        description: ''
        author: ''
        analyticssiteid: 'XXXXXXX'
        error: err 
      status: 500 
    }

app.set('views', __dirname + '/views')
app.set('view engine', 'jade')

require('./repos/routes')(app)

app.get '/500', (req, res) ->
  throw new Error('This is a 500 Error')

app.get '/*', (req, res) ->
  throw new NotFound()

NotFound = (msg) ->
  this.name = 'NotFound'
  Error.call this, msg
  Error.captureStackTrace this, arguments.callee


app.listen(port)
console.log("Server listening at port #{port}")