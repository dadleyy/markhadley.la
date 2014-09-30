mh.directive 'mhPlaylist', ['Viewport', 'Loop', (Viewport, Loop) ->

  tof = (num) ->
    parseFloat num

  arc_width = 15
  arc_spacing = 2
  arc_inc = arc_width + arc_spacing
  start_radius = 60
  SPIN_SPEED = 0.5

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
      speeds = []
      arc_gen = null
      loop_id = null
      width = 100
      height = 100
      theta = 0

      speeds.push randspeed(index) for track, index in $scope.playlist.tracks

      arcInner = (data, indx) ->
        start_radius + (indx * arc_inc)

      arcOuter = (data, indx) ->
        arcInner(null, indx) + arc_width

      arcEnd = (data, indx) ->
        percent = tof(data.duration) / total_duration
        radians = (360 * percent) * (Math.PI / 180)

      arcStart = (data, indx) -> 0

      addPlaylist = (track, indx) ->
        grp = svg.append 'g'
        path = grp.append 'path'

        grp.attr 'data-track', track.title
        path.attr 'd', () -> arc_gen(track, indx)
        path.attr 'fill', 'red'

        rings.push grp

      position = (ring, indx) ->
        translate = ['translate(', width * 0.5, ',', height * 0.5, ')'].join ''
        rotate = ['rotate(', theta * speeds[indx], ')'].join ''
        ring.attr 'transform', [translate, rotate].join(' ')

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
        theta += SPIN_SPEED
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
      addPlaylist track, index for track, index in $scope.playlist.tracks
      resize()
      $scope.$on 'playlist_change', toggle

]
