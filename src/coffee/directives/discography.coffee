mh.directive 'mhDiscography', ['Viewport', (Viewport) ->

  mDiscography =
    replace: true
    templateUrl: 'directives.discography'
    scope:
      playlists: '='
    link: ($scope, $element, $attrs) ->
      $scope.active_index = 0

      $scope.nav = (inc) ->
        $scope.active_index += inc

        if $scope.active_index < 0
          $scope.active_index = $scope.playlists.length

        if $scope.active_index > $scope.playlists.length - 1
          $scope.active_index = 0


]
