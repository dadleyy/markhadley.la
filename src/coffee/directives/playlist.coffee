mh.directive 'mhPlaylist', ['Viewport', 'Loop', 'Audio', 'COLORS', (Viewport, Loop, Audio, COLORS) ->

  tof = (num) ->
    parseFloat num

  arc_width = 15
  arc_spacing = 2
  arc_inc = arc_width + arc_spacing
  start_radius = 60
  SPIN_SPEED = 0.5

  class TrackRing

    constructor: (@track, @group, @path, @speed) ->
      @position = { x: 0, y: 0 }
      @rotation = (Math.random() * 1000) % 360
      @stopped = false
      @playing = false
      @listeners =
        click: []
        mouseout: []
        mouseover: []

      was_click = false


      trigger = (evt) =>
        fn() for fn in @listeners[evt]

      over = () =>
        @stopped = true
        @scale = 1.2
        trigger 'mouseover'
      
      out = () =>
        @stopped = false
        @scale = 1.0
        trigger 'mouseout'
  
      click = () =>
        was_click = true
        @playing = !@playing

        if @playing
          Audio.play @track
        else
          Audio.stop()

        trigger 'click'
        was_click = false

      stopped = () =>
        unless was_click
          @playing = false

      @group
        .on 'mouseover', over
        .on 'mouseout', out
        .on 'click', click

      Audio
        .on 'stop', stopped

    move: (x_pos, y_pos) ->
      @position.x = x_pos
      @position.y = y_pos

    rotate: (degrees) ->
      unless @stopped or @playing
        @rotation += degrees * @speed

    update: () ->
      translate = ['translate(', @position.x, ',', @position.y, ')'].join ''
      rotate = ['rotate(', @rotation, ')'].join ''
      @group.attr 'transform', [translate, rotate].join(' ')

    on: (evt, fn) ->
      if @listeners[evt] && angular.isFunction(fn)
        @listeners[evt].push fn
      @

  randspeed = (indx) ->
    large = (Math.random() * 100) % 2
    large - 1
    if large < 0.5 and large > -0.5
      large *= 2
    if indx % 2 == 0 then large else -large

  mhPlaylist =
    replace: true
    templateUrl: 'directives.playlist'
    scope:
      playlist: '='
      index: '='
    link: ($scope, $element, $attrs) ->
      $scope.active = null
      d_el = d3.select($element[0]).select '.playlist-guts'
      svg = d_el.append 'svg'
      total_duration = 0
      rings = []
      arc_gen = null
      loop_id = null
      width = 100
      height = 100
      hover_indx = null

      arcInner = (data, indx) ->
        inner_radius = start_radius + (indx * arc_inc)
        inner_radius += if indx == hover_indx then -5 else 0

      arcOuter = (data, indx) ->
        outer_radius = arcInner(null, indx) + arc_width
        outer_radius += if indx == hover_indx then 10 else 0

      arcEnd = (data, indx) ->
        percent = tof(data.duration) / total_duration
        radians = (360 * percent) * (Math.PI / 180)

      arcStart = (data, indx) -> 0

      addTrack = (track, indx) ->
        grp = svg.append 'g'
        path = grp.append 'path'

        grp.attr 'data-track', track.title
        path.attr 'd', () -> arc_gen(track, indx)

        if COLORS.tracks[track.id]
          path.attr 'fill', COLORS[track.id]
        else if COLORS.playlists[$scope.playlist.id]
          playlist_colors = COLORS.playlists[$scope.playlist.id]
          color_indx = indx % playlist_colors.length
          console.log playlist_colors[color_indx]
          path.attr 'fill', playlist_colors[indx % playlist_colors.length]
        else
          path.attr 'fill', 'red'

        ring = new TrackRing track, grp, path, randspeed(indx)

        over = () ->
          hover_indx = indx
          path.attr 'd', () -> arc_gen(track, indx)

        out = () ->
          hover_indx = null
          path.attr 'd', () -> arc_gen(track, indx)

        ring
          .on 'mouseover', over
          .on 'mouseout', out

        rings.push ring

      position = (ring, indx) ->
        ring.move width * 0.5, height * 0.5
        ring.rotate SPIN_SPEED
        ring.update()

      resize = () ->
        width = $element[0].offsetWidth
        height = $element[0].offsetHeight

        svg.attr
          width: width
          height: height

        position ring, rindx for ring, rindx in rings

      arc_gen = d3.svg.arc()
        .startAngle arcStart
        .endAngle arcEnd
        .innerRadius arcInner
        .outerRadius arcOuter

      spin = () ->
        position ring, rindx for ring, rindx in rings

      stopSpin = () ->
        if loop_id
          Loop.remove loop_id
        loop_id = null

      startSpin = () ->
        loop_id = Loop.add spin

      toggle = (evt, active_index) ->
        if active_index == $scope.index
          startSpin()
        else
          stopSpin()

      total_duration += tof(track.duration) for track in $scope.playlist.tracks
      Viewport.addListener resize
      addTrack track, index for track, index in $scope.playlist.tracks
      resize()
      $scope.$on 'playlist_change', toggle

]
