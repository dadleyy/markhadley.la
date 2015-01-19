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

    rotate: (degrees) ->
      @rotation = degrees
      rotate = ['rotate(', @rotation, ')'].join ''
      @path.attr 'transform': rotate

    update: () ->

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
          play_inner = 80
          play_inner
        else
          indx = find(track)
          inner_radius = start_radius + (indx * arc_inc)

      outer = (track) ->
        if $scope.active
          play_outer = 95
          play_outer
        else
          indx = find(track)
          inner_radius = start_radius + (indx * arc_inc)
          outer_radius = inner_radius + arc_width

      end = (track, indx) ->
        end_angle = 0
        if $scope.active
          start_angle = start track, indx
          angle_width = radians track.track
          end_angle = start_angle + angle_width
        else
          end_angle = radians track.track
        end_angle

      start = (track, indx) ->
        start_angle = 0
        if $scope.active and indx > 0
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

      arc_gen.playback = d3.svg.arc()
        .startAngle () -> 0
        .endAngle (active_track) ->
          duration = active_track.duration()
          position = active_track.position()
          percent = position / duration
          (360 * percent) * (Math.PI / 180)
        .innerRadius () -> 75
        .outerRadius () -> 60

      arc_gen

]
