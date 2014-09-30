mh.directive 'mhDiscography', ['Viewport', (Viewport) ->

  mDiscography =
    replace: true
    templateUrl: 'directives.discography'
    scope:
      playlists: '='
    link: ($scope, $element, $attrs) ->
      $scope.active_index = 0

]
