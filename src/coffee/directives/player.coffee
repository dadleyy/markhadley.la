mh.directive 'mhPlayer', ['Audio', (Audio) ->

  mhPlayer =
    replace: true
    templateUrl: 'directives.player'
    require: '^mhPlaylist'
    scope:
      track: '='
    link: ($scope, $element, $attrs, playlist_controller) ->
      $scope.stop = () ->
        $scope.track.pause()

      $scope.play = () ->
        $scope.track.play()

      $scope.next = () ->
        playlist_controller.playNext()

      $scope.back = () ->
        playlist_controller.playPrevious()

      $scope.playing = () ->
        $scope.track.isPlaying()


]
