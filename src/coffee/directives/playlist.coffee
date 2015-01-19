mh.directive 'mhPlaylist', ['Viewport', 'Loop', 'Audio', 'Drawing', (Viewport, Loop, Audio, Drawing) ->

  tof = (num) ->
    parseFloat num

  toi = (num) -> parseInt num

  SPIN_SPEED = 0.2

  randspeed = (indx) ->
    large = ((Math.random() * 100) % 0.5) + 0.1
    if indx % 2 == 0 then large else -large

  getColor = (track, indx) ->
    colors = @scope.colors
    playlist_id = @playlist.id

    for color_list in colors
      list_id = toi color_list.id
      if list_id == track.id
        fount_color = color_list.color
      else if list_id == playlist_id
        color_options = color_list.color.split ','
        found_color = color_options[indx % color_options.length]

    cleansed = (found_color or '#fff').replace /\s/g, ''
    ['#', cleansed].join ''

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
      @ring_container = @svg.append 'g'
      @playback_ring = @ring_container.append 'p'
      @arc = Drawing.arcFactory $scope
      @width = 100
      @height = 100
      @playlist = @scope.playlist
      @active_index = -1
      @playlist_rotation = 0

    playNext: () -> nav.call @, 1

    playPrevious: () -> nav.call @, -1

    draw: () ->
      @playlist_rotation += SPIN_SPEED

      if @active_index >= 0
        @playback_ring.attr

      for ring, indx in @rings
        offset = @rotation_offsets[indx]
        if @scope.active
          ring.rotate @playlist_rotation
        else
          rotation = if indx % 2 == 0 then -@playlist_rotation else @playlist_rotation
          ring.rotate offset + rotation

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
      @ring_container.attr
        transform: 'translate('+(left)+','+(top)+')'

    open: () ->
      @center()

      @playback_ring.attr
        'opacity': '1.0'

      for r, indx in @rings
        instance = @tracks[indx]

        opacity = if instance.playing then '1.0' else '0.5'
        r.path.transition().duration(400).ease('elastic').attr
          'opacity': opacity
          'd': @arc.fn instance, indx

        r.speed = 0.2

    close: () ->
      if @scope.active
        @scope.active.stop()

      @scope.active = null
      @active_index = -1

      @playback_ring.attr
        'opacity': '0.0'

      @center()

      for r, indx in @rings
        instance = @tracks[indx]

        r.path.transition().duration(400).ease('elastic').attr
          'opacity': '1.0'
          'd': @arc.fn instance, indx

        r.speed = randspeed indx

      try
        @scope.$digest()
      catch
        return false

    addTrack: (track) ->
      indx = @tracks.length
      was_clicked = false
      group = @ring_container.append 'g'
      path = group.append 'path'
      fill_color = getColor.call @, track, indx
      group.attr 'data-track', track.title

      instance = new Audio.Track track
      arc_fn = () => @arc.fn instance, indx

      path.attr
        'fill': fill_color
        'd': arc_fn()

      ring = new Drawing.Ring group, path, arc_fn
      @rotation_offsets.push (Math.random() * 1000) % 360

      clickfn = () =>
        if instance.playing
          instance.stop()
        else
          was_clicked = true
          instance.play()
          was_clicked = false

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
      colors: '='
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
