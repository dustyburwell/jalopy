proc = require('child_process')

task 'build', 'build jalopy', (options) ->
  {}

task 'test', 'test jalopy', (options) ->
  reporter = require('nodeunit').reporters.default
  reporter.run ['test']
