mh.directive 'mhPlaylist', ['Viewport', 'Loop', 'Audio', 'Drawing', 'COLORS', (Viewport, Loop, Audio, Drawing, COLORS) ->

  tof = (num) ->
    parseFloat num

  SPIN_SPEED = 0.2

  randspeed = (indx) ->
    large = ((Math.random() * 100) % 0.5) + 0.1
    if indx % 2 == 0 then large else -large

  getColor = (track, indx, playlist) ->
    found_color = '#fff'
    if COLORS.tracks and COLORS.tracks[track.id]
      found_color = COLORS.tracks[track.id]
    else if COLORS.playlists and COLORS.playlists[playlist.id]
      playlist_colors = COLORS.playlists[playlist.id]
      color_indx = indx % playlist_colors.length
      found_color = playlist_colors[indx % playlist_colors.length]
    found_color

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
      @rotation_offsets = []
      @svg = d3.select($element[0]).append 'svg'
      @arc = Drawing.arcFactory $scope
      @width = 100
      @height = 100
      @playlist = @scope.playlist
      @active_index = 0
      @playlist_rotation = 0

    playNext: () -> nav.call @, 1

    playPrevious: () -> nav.call @, -1

    draw: () ->
      @playlist_rotation += SPIN_SPEED

      for ring, indx in @rings
        offset = @rotation_offsets[indx]
        if !@tracks[indx].playing and @scope.active
          ring.rotate @playlist_rotation

        else if !@tracks[indx].playing and !@scope.active
          rotation = if indx % 2 == 0 then -@playlist_rotation else @playlist_rotation
          ring.rotate offset + rotation

        else
          ring.rotate 0

        ring.update()

    resize: (width, height) ->
      @width = width
      @height = height
      @svg.attr
        width: @width
        height: @height
      @center()
      @draw()

    center: () ->
      width = @width
      height = @height
      top = if @scope.active then 120 else height * 0.5
      left = width * 0.5
      ring.move left, top for ring in @rings

    open: () ->
      @center()
      for r in @rings
        r.path.attr 'opacity', '0.5'
        r.speed = 0.2

    close: () ->
      if @scope.active
        @scope.active.stop()

      @scope.active = null
      @center()
      for r, indx in @rings
        r.path.attr 'opacity', '1.0'
        r.speed = randspeed(indx)

      try
        @scope.$digest()
      catch
        return false

    addTrack: (track) ->
      indx = @tracks.length
      was_clicked = false
      group = @svg.append 'g'
      path = group.append 'path'
      fill_color = getColor track, indx, @playlist
      path.attr 'fill', fill_color
      group.attr 'data-track', track.title

      instance = new Audio.Track track
      arc_fn = () => @arc.fn instance, indx
      ring = new Drawing.Ring group, path, arc_fn
      @rotation_offsets.push (Math.random() * 1000) % 360

      clickfn = () =>
        if instance.playing
          instance.stop()
        else
          was_clicked = true
          instance.play()
          was_clicked = false

      playing = () -> ring.update()

      stopped = () =>
        @scope.active = null
        @close()

      started = () =>
        @scope.active = instance
        @active_index = indx
        @open()
        try
          @scope.$digest()
        catch
          false
        @scope.$broadcast 'playback_start', instance
      mouseover = () =>
      mouseout = () =>

      ring
        .on 'click', clickfn
        .on 'mouseover', mouseover
        .on 'mouseout', mouseout

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
