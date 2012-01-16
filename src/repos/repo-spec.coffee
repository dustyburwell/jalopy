describe "Memory repository", ->
  repo = require './repos'
  mock = require './mockdir'
  
  beforeEach ->
    repo.enableMock()
    mock.reset()

  describe "When listing repos", ->
    
    it "should list all repositories in the directory", ->
      actual_list = null

      repo.list (err, list) ->
        actual_list = list

      waitsFor () -> 
        actual_list
      , 'list never returned', 1000
   
      runs () ->
        expect(actual_list).toEqual([
          "AppArch/Security",
          "Illuminate/Insight",
          "Panther/Panther"
          ])

    it "should list all the repositories in the owner directory", ->
      actual_list = null

      repo.list 'Illuminate', (err, list) ->
        actual_list = list

      waitsFor () -> 
        actual_list
      , 'list never returned', 1000
   
      runs () ->
        expect(actual_list).toEqual([
          "Illuminate/Insight"
          ])

  describe "When creating a repo", ->
    it "should add the repo to the directory", ->
      actual_list = null

      repo.add 'Illuminate', 'ActKnowledge', () ->
        repo.list (err, list) ->
          actual_list = list

      waitsFor () -> 
        actual_list
      , 'list never returned', 1000
   
      runs () ->
        expect(actual_list).toEqual([
          "AppArch/Security",
          "Illuminate/ActKnowledge"
          "Illuminate/Insight",
          "Panther/Panther"
          ])


describe "Directory repository", ->
  repo = require './repos'
  
  beforeEach ->
    this._git_directory = process.env['JALOPY_GIT_DIRECTORY']
    process.env['JALOPY_GIT_DIRECTORY'] = '/test/git/directory'
    repo.disableMock()
 
  afterEach ->
    process.env['JALOPY_GIT_DIRECTORY'] = this._git_directory

  describe "When listing repositories", ->
    path = require 'path'
    fs   = require 'fs'

    it "should list all repos for all owners", ->
      actual_list = null

      spyOn(fs, 'readdir').andCallFake (path, callback) ->
        switch path
          when '/test/git/directory' then callback null, ['Illuminate', 'OnTrack']
          when '/test/git/directory/OnTrack' then callback null, ['Panther']
          when '/test/git/directory/Illuminate' then callback null, ['Insight']

      repo.list (err, list) ->
        actual_list = list

      waitsFor () ->
        actual_list
      , 'list never returned', 1000

      runs () ->
        expect(actual_list).toEqual ['Illuminate/Insight', 'OnTrack/Panther']
        expect(fs.readdir).toHaveBeenCalledWith('/test/git/directory', jasmine.any(Function))
        expect(fs.readdir).toHaveBeenCalledWith('/test/git/directory/OnTrack', jasmine.any(Function))
        expect(fs.readdir).toHaveBeenCalledWith('/test/git/directory/Illuminate', jasmine.any(Function))

    it "should list all repos for the owner", ->
      actual_list = null

      spyOn(path, 'exists').andCallFake (path, callback) ->
        callback true
      spyOn(fs, 'readdir').andCallFake (path, callback) ->
        switch path
          when '/test/git/directory/OnTrack' then callback null, ['DiscoveryAudit', 'Panther']

      repo.list 'OnTrack', (err, list) ->
        actual_list = list

      waitsFor () ->
        actual_list
      , 'list never returned', 1000

      runs () ->
        expect(actual_list).toEqual ['OnTrack/DiscoveryAudit', 'OnTrack/Panther']
        expect(fs.readdir).toHaveBeenCalledWith('/test/git/directory/OnTrack', jasmine.any(Function))
      
    it "should fail if the owner doesn't exist", ->
      actual_err = null

      spyOn(path, 'exists').andCallFake (path, callback) ->
        callback false

      repo.list 'OnTrack', (err, list) ->
        actual_err = err

      waitsFor () ->
        actual_err
      , 'list never returned', 1000

      runs () ->
        expect(actual_err.message).toEqual 'No owner'
        #expect(fs.readdir).toHaveBeenCalledWith('/test/git/directory/OnTrack', jasmine.any(Function))

  describe "When adding a repository", ->
    path = require 'path'
    tree = require('treeeater')

    it "should fail if the owner doesn't exist", ->
      error = null;
      callback = false

      spyOn(path, 'exists').andCallFake (path, callback) ->
        callback false

      repo.add 'OnTrack', 'Panther', (err) ->
        error = err;
        callback = true

      waitsFor () ->
        callback
      , 'add repository never returned', 1000

      runs () ->
        expect(path.exists).toHaveBeenCalledWith('/test/git/directory/OnTrack', jasmine.any(Function))
        expect(error).toNotBe(null)

    it "should fail if the repository exists", ->
      error = null;
      callback = false

      spyOn(path, 'exists').andCallFake (path, callback) ->
        callback true

      repo.add 'OnTrack', 'Panther', (err) ->
        error = err;
        callback = true

      waitsFor () ->
        callback
      , 'add repository never returned', 1000

      runs () ->
        expect(path.exists).toHaveBeenCalledWith('/test/git/directory/OnTrack', jasmine.any(Function))
        expect(path.exists).toHaveBeenCalledWith('/test/git/directory/OnTrack/Panther', jasmine.any(Function))
        expect(error).toNotBe(null)

    it "should initialize the repo", ->
      callback = false
      gitSpy = jasmine.createSpyObj('Git', ['init'])
      gitCwd = null

      spyOn(path, 'exists').andCallFake (path, callback) ->
        switch path
          when '/test/git/directory/OnTrack' then callback true
          when '/test/git/directory/OnTrack/Panther' then callback false
          else callback false

      spyOn(tree, 'Git').andCallFake (options) ->
        gitCwd = options.cwd
        gitSpy

      gitSpy.init.andCallFake (args..., callback) ->
        callback null

      repo.add 'OnTrack', 'Panther', (err) ->
        callback = true

      waitsFor () ->
        callback
      , 'add repository never returned', 1000

      runs () ->
        expect(tree.Git).toHaveBeenCalled()
        expect(gitCwd).toEqual '/test/git/directory/OnTrack'
        expect(gitSpy.init).toHaveBeenCalledWith('--bare', 'Panther', jasmine.any(Function))
