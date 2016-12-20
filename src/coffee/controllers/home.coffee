HomeController = ($scope, playlists, colors) ->

  featured = []
  for pl in playlists
    tags = pl.tag_list
    is_featured = /featured/i.test tags
    if is_featured
      featured.push pl

  $scope.playlists = featured
  $scope.colors = colors

HomeController.$inject = ["$scope", "playlists", "colors"]

mh.controller "HomeController", HomeController
