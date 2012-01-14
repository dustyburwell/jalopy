#!/usr/bin/env node

express = require 'express'
sys = require 'sys'
app = express.createServer()

port = process.env.PORT || 3000
gitdir = process.env.JALOPY_GIT_DIRECTORY || '/Users/dusty/Workspace'

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

app.set('views', __dirname + '/views')
app.set('view engine', 'jade')


require('./controllers/repos')(app)


app.listen(port)
console.log("Server listening at port #{port}")