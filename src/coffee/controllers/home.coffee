do () =>

  HomeController = ($scope, playlists, about_page, colors) ->

    featured = []
    for pl in playlists
      tags = pl.tag_list
      is_featured = /featured/i.test tags
      if is_featured
        featured.push pl

    $scope.playlists = featured
    $scope.about_page = about_page
    $scope.colors = colors
  
  HomeController.$inject = ['$scope', 'playlists', 'about_page', 'colors']

  mh.controller 'HomeController', HomeController
