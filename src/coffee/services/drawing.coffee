mh.service 'Drawing', [() ->

  arc_width = 15
  arc_spacing = 2
  arc_inc = arc_width + arc_spacing
  start_radius = 60

  tof = (num) ->
    parseFloat num

  class Ring

    constructor: (@group, @path, @speed) ->
      @position = { x: 0, y: 0 }
      @rotation = (Math.random() * 1000) % 360
      @stopped = false
      @arc_gen = d3.svg.arc()
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

    rotate: (degrees) ->
      unless @stopped
        @rotation += degrees * @speed

    update: () ->
      translate = ['translate(', @position.x, ',', @position.y, ')'].join ''
      rotate = ['rotate(', @rotation, ')'].join ''
      path = @arc_gen()
      @group.attr 'transform', [translate, rotate].join(' ')
      @path.attr 'd', path

    on: (evt, fn) ->
      if @listeners[evt] && angular.isFunction(fn)
        @listeners[evt].push fn
      @

    setGen: (generator) ->
      if angular.isFunction generator
        @arc_gen = generator

  Drawing =
    
    Ring: Ring

    arcFactory: (playlist) ->
      arc_gen = {}
      total_duration = 0
      total_duration += tof(track.duration) for track in playlist.tracks
      hover_indx = -1

      find = (target) ->
        found = -1
        for track, index in playlist.tracks
          if track.id == target.id
            found = index
        found
      
      inner = (mod) ->
        (track) ->
          indx = find(track)
          inner_radius = start_radius + (indx * arc_inc)
          inner_radius += mod

      outer = (mod) ->
        (track) ->
          indx = find(track)
          inner_radius = start_radius + (indx * arc_inc)
          outer_radius = inner_radius + arc_width
          outer_radius += mod

      end = (track, indx) ->
        percent = tof(track.duration) / total_duration
        radians = (360 * percent) * (Math.PI / 180)

      start = (track, indx) -> 0

      calc = (track, played) ->
        percent = tof(played) / tof(track.duration)
        radians = (360 * percent) * (Math.PI / 180)

      arc_gen.standard = d3.svg.arc()
        .startAngle start
        .endAngle end
        .innerRadius inner(0)
        .outerRadius outer(0)

      arc_gen.fat = d3.svg.arc()
        .startAngle start
        .endAngle end
        .innerRadius inner(-5)
        .outerRadius outer(5)

      arc_gen.playing = d3.svg.arc()
        .startAngle start
        .endAngle calc
        .innerRadius () -> 40
        .outerRadius () -> 40 + arc_width

      arc_gen

]
