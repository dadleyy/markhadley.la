do () =>

  HomeController = ($scope, playlists, bio_content, bio_info) ->

    $scope.playlists = playlists
    $scope.bio_content = bio_content
    $scope.bio_info = bio_info
  
  HomeController.$inject = ['$scope', 'playlists', 'bio_content', 'bio_info']
  mh.controller 'HomeController', HomeController
