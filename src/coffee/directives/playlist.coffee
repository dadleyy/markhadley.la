mh.directive 'mhPlaylist', ['Viewport', 'Loop', 'Audio', 'Drawing', 'COLORS', (Viewport, Loop, Audio, Drawing, COLORS) ->

  tof = (num) ->
    parseFloat num

  SPIN_SPEED = 0.5

  randspeed = (indx) ->
    large = ((Math.random() * 100) % 0.5) + 0.1
    if indx % 2 == 0 then large else -large

  nav = (dir) ->
    next = @active_index + dir

    if next > @tracks.length - 1
      next = 0
    else if next < 0
      next = @tracks.length - 1
    
    @tracks[next].play()


  class PlaylistController

    constructor: ($scope, $element) ->
      @scope = $scope
      @rings = []
      @tracks = []
      @svg = d3.select($element[0]).append 'svg'
      @arc = Drawing.arcFactory $scope
      @width = 100
      @height = 100
      @playlist = @scope.playlist
      @active_index = 0

    playNext: () -> nav.call @, 1

    playPrevious: () -> nav.call @, -1

    draw: () ->
      width = @width
      height = @height

      for ring, indx in @rings
        ring.move width * 0.5, height * 0.5

        if !@tracks[indx].playing and !@scope.active
          ring.rotate SPIN_SPEED
        else
          ring.rotation = 0

        ring.update()

    resize: (width, height) ->
      @width = width
      @height = height
      @svg.attr
        width: @width
        height: @height
      @draw()

    addTrack: (track) ->
      indx = @tracks.length
      was_clicked = false

      group = @svg.append 'g'
      path = group.append 'path'

      if COLORS.tracks[track.id]
        path.attr 'fill', COLORS.tracks[track.id]
      else if COLORS.playlists[@playlist.id]
        playlist_colors = COLORS.playlists[@playlist.id]
        color_indx = indx % playlist_colors.length
        path.attr 'fill', playlist_colors[indx % playlist_colors.length]
      else
        path.attr 'fill', '#ffffff'

      group.attr 'data-track', track.title

      instance = new Audio.Track track

      arc_fn = () =>
        @arc.fn instance, indx

      ring = new Drawing.Ring group, path, randspeed(indx), arc_fn

      clickfn = () =>
        if instance.playing
          instance.stop()
        else
          was_clicked = true
          instance.play()
          was_clicked = false

      playing = () -> ring.update()

      stopped = () =>
        if was_clicked
          return false

        @scope.active = null
        r.rotation = (Math.random() * 1000) % 360 for r in @rings
        try
          @scope.$digest()
        catch
          return false

      started = () =>
        @scope.active = instance
        @active_index = indx
        try
          @scope.$digest()
        catch
          false
        @scope.$broadcast 'playback_start', instance

      ring
        .on 'click', clickfn

      instance
        .on 'playback', playing
        .on 'stop', stopped
        .on 'start', started

      @rings.push ring
      @tracks.push instance

  PlaylistController.$inject = ['$scope', '$element']

  mhPlaylist =
    replace: true
    templateUrl: 'directives.playlist'
    controller: PlaylistController
    scope:
      playlist: '='
      index: '='
    link: ($scope, $element, $attrs, playlist_controller) ->
      $scope.active = null
      loop_id = null

      resize = () ->
        width = $element[0].offsetWidth
        height = $element[0].offsetHeight
        playlist_controller.resize width, height

      spin = () ->
        playlist_controller.draw()

      stopSpin = () ->
        if loop_id
          Loop.remove loop_id
        loop_id = null

      startSpin = () ->
        loop_id = Loop.add spin

      toggle = (evt, active_index) ->
        if active_index == $scope.index then startSpin() else stopSpin()

      Viewport.addListener resize
      playlist_controller.addTrack track for track in $scope.playlist.tracks
      resize()

      $scope.$on 'playlist_change', toggle

]
