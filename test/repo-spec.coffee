repo = require '../src/repos/repos'
mock = require '../src/repos/mockdir'
repo.enableMock()

describe "Repos", ->
  beforeEach ->
    mock.reset()

  describe "When listing repos", ->
    
    it "should list all repositories in the directory", ->
      actual_list = null

      repo.list (list) ->
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

      repo.list 'Illuminate', (list) ->
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
        repo.list (list) ->
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

describe "repo directory", ->
  process.env['JALOPY_GIT_DIRECTORY'] = '/test/git/directory'
  dir = require '../src/repos/dir'

  ###
  beforeEach ->
    this._openStdin = process.openStdin
 
  afterEach ->
    process.openStdin = this._openStdin
  ###

  describe "When listing repositories", ->
    fs = require 'fs'

    it "should query the file system", ->
      actual_list = null

      spyOn(fs, 'readdir').andCallFake (path, callback) ->
        switch path
          when '/test/git/directory' then callback null, ['OnTrack']
          else callback null, ['Panther']

      dir.list (list) ->
        actual_list = list

      waitsFor () ->
        actual_list
      , 'list never returned', 1000

      runs () ->
        expect(actual_list).toEqual ['OnTrack/Panther']
        expect(fs.readdir).toHaveBeenCalledWith('/test/git/directory', jasmine.any(Function));
        expect(fs.readdir).toHaveBeenCalledWith('/test/git/directory/OnTrack', jasmine.any(Function));
      

