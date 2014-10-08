do () =>

  HomeController = ($scope, playlists, bio_content, bio_info) ->

    featured = []
    for pl in playlists
      tags = pl.tag_list
      is_featured = /featured/i.test tags
      if is_featured
        featured.push pl

    $scope.playlists = featured
    $scope.bio_content = bio_content
    $scope.bio_info = bio_info
  
  HomeController.$inject = ['$scope', 'playlists', 'bio_content', 'bio_info']
  mh.controller 'HomeController', HomeController
