mh.service 'Drawing', [() ->

  arc_width = 15
  arc_spacing = 2
  arc_inc = arc_width + arc_spacing
  start_radius = 60

  tof = (num) ->
    parseFloat num

  class Ring

    constructor: (@group, @path, @arc_fn) ->
      @position = { x: 0, y: 0 }
      @rotation = (Math.random() * 1000) % 360
      @stopped = false
      @listeners =
        click: []
        mouseout: []
        mouseover: []

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
        trigger 'click'

      @group
        .on 'mouseover', over
        .on 'mouseout', out
        .on 'click', click

    move: (x_pos, y_pos) ->
      @position.x = x_pos
      @position.y = y_pos
      translate = ['translate(', @position.x, ',', @position.y, ')'].join ''
      @group.attr 'transform', [translate].join(' ')

    rotate: (degrees) ->
      @rotation = degrees

    update: () ->
      rotate = ['rotate(', @rotation, ')'].join ''
      path = @arc_fn()
      @path.attr 'transform': rotate
      @path.attr 'd', path

    on: (evt, fn) ->
      if @listeners[evt] && angular.isFunction(fn)
        @listeners[evt].push fn
      @

  Drawing =
    
    Ring: Ring

    arcFactory: ($scope) ->
      playlist = $scope.playlist
      arc_gen = {}
      total_duration = 0
      total_duration += tof(track.duration) for track in playlist.tracks
      hover_indx = -1

      radians = (track) ->
        duration = track.duration
        percent = tof(duration) / total_duration
        rads = (360 * percent) * (Math.PI / 180)

      find = (target) ->
        found = -1
        for track, index in playlist.tracks
          if track.id == target.id
            found = index
        found
      
      inner = (track) ->
        if $scope.active
          play_inner = if track.playing then 20 else 80
          play_inner
        else
          indx = find(track)
          inner_radius = start_radius + (indx * arc_inc)

      outer = (track) ->
        if $scope.active
          play_outer = if track.playing then 35 else 95
          play_outer
        else
          indx = find(track)
          inner_radius = start_radius + (indx * arc_inc)
          outer_radius = inner_radius + arc_width

      end = (track, indx) ->
        end_angle = 0
        if track.playing
          end_angle = calc track, track.position()
        else
          if $scope.active
            start_angle = start track, indx
            angle_width = radians track.track
            end_angle = start_angle + angle_width
          else
            end_angle = radians track.track
        end_angle

      start = (track, indx) ->
        start_angle = 0
        if $scope.active and indx > 0 and !track.playing
          prev_track = playlist.tracks[indx - 1]
          prev_start = start prev_track, indx - 1
          prev_width = radians prev_track
          start_angle = prev_start + prev_width
        start_angle

      calc = (track, played) ->
        duration = track.duration()
        percent = tof(played) / tof(duration)
        rads = (360 * percent) * (Math.PI / 180)

      arc_gen.fn = d3.svg.arc()
        .startAngle start
        .endAngle end
        .innerRadius inner
        .outerRadius outer

      arc_gen

]
