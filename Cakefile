exec = require('child_process').exec
path = require('path')

task 'build', 'build jalopy', (options) ->
  {}

#task 'test', 'test jalopy', (options) ->
#  reporter = require('nodeunit').reporters.default
#  reporter.run ['test']

task "test", "Run test (spec) suite", (options) ->
  exec "jasmine-node --coffee #{'--verbose ' if options.verbose}#{'--teamcity ' if options.teamcity} --match .*- ./", (err, stdout, stderr) ->
    console.log stdout
    console.log "Error: #{stderr}" if stderr