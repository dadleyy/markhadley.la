mh.directive "mhDiscography", ["$timeout", "Viewport", "Audio", ($timeout, Viewport, Audio) ->

  mDiscography =
    replace: true
    templateUrl: "directives.discography"
    scope:
      colors: "="
      playlists: "="
    link: ($scope, $element, $attrs) ->
      $scope.active_index = 0

      $scope.nav = (inc) ->
        right_bound = $scope.playlists.length - 1
        $scope.active_index += inc
        Audio.stop()

        if $scope.active_index < 0
          $scope.active_index = 0

        if $scope.active_index > right_bound
          $scope.active_index = right_bound

        $scope.$broadcast "playlist_change", $scope.active_index

      init = () ->
        $scope.$broadcast "playlist_change", 0

      $timeout init


]
