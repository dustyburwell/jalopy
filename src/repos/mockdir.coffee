
class RepositoryDirectory
  constructor: () ->
    return

  reset: () ->
    @repos = [ 'AppArch/Security', 'Illuminate/Insight', 'Panther/Panther' ]

  list: (args..., callback) ->
    owner = if args.length then args.shift() else null

    repos = 
      if owner
        (repo for repo in @repos when repo.indexOf(owner) == 0).sort()
      else
        @repos.sort()

    callback(null, repos)

  add: (owner, name, callback) ->
    @repos.unshift "#{owner}/#{name}"
    callback null


module.exports = new RepositoryDirectory()