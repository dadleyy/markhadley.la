mh.directive 'mhPlaylist', ['Viewport', 'Loop', (Viewport, Loop) ->

  tof = (num) ->
    parseFloat num

  arc_width = 15
  arc_spacing = 2
  arc_inc = arc_width + arc_spacing
  start_radius = 60
  SPIN_SPEED = 0.5

  class Ring

    constructor: (@group, @path, @speed) ->
      @position = { x: 0, y: 0 }
      @rotation = 0
      @stopped = false
      @listeners =
        click: []

      over = () =>
        @stopped = true
      
      out = () =>
        @stopped = false
  
      click = () =>
        fn() for fn in @listeners['click']

      @group
        .on 'mouseover', over
        .on 'mouseout', out
        .on 'click', click

    move: (x_pos, y_pos) ->
      @position.x = x_pos
      @position.y = y_pos

    rotate: (degrees) ->
      unless @stopped
        @rotation += degrees * @speed

    update: () ->
      translate = ['translate(', @position.x, ',', @position.y, ')'].join ''
      rotate = ['rotate(', @rotation, ')'].join ''
      @group.attr 'transform', [translate, rotate].join(' ')

    on: (evt, fn) ->
      if @listeners[evt] && angular.isFunction(fn)
        @listeners[evt].push fn

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
      d_el = d3.select $element[0]
      svg = d_el.append 'svg'
      total_duration = 0
      rings = []
      arc_gen = null
      loop_id = null
      width = 100
      height = 100

      arcInner = (data, indx) ->
        start_radius + (indx * arc_inc)

      arcOuter = (data, indx) ->
        arcInner(null, indx) + arc_width

      arcEnd = (data, indx) ->
        percent = tof(data.duration) / total_duration
        radians = (360 * percent) * (Math.PI / 180)

      arcStart = (data, indx) -> 0

      addTrack = (track, indx) ->
        grp = svg.append 'g'
        path = grp.append 'path'

        grp.attr 'data-track', track.title
        path.attr 'd', () -> arc_gen(track, indx)
        path.attr 'fill', 'red'

        ring = new Ring grp, path, randspeed(indx)

        click = () ->
          console.log track

        ring.on 'click', click
        rings.push ring

      position = (ring, indx) ->
        ring.move width * 0.5, height * 0.5
        ring.rotate SPIN_SPEED
        ring.update()

      resize = () ->
        total_duration += tof(track.duration) for track in $scope.playlist.tracks
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

      Viewport.addListener resize
      addTrack track, index for track, index in $scope.playlist.tracks
      resize()
      $scope.$on 'playlist_change', toggle

]
