mh.service 'Audio', ['$q', 'SOUNDCLOUD_KEY', ($q, SOUNDCLOUD_KEY) ->

  soundManager.setup
    debugMode: false

  active_track = null
  listeners =
    start: []
    stop: []
    finish: []

  trigger = (evt) ->
    if listeners[evt]
      fn() for fn in listeners[evt]

  Audio =

    on: (evt, fn) ->
      if listeners[evt] and angular.isFunction(fn)
        listeners[evt].push fn
      Audio

    play: (track) ->
      stop() if active_track

      streaming_url = track.stream_url
      client_params = ['client_id', SOUNDCLOUD_KEY].join '='

      active_track = soundManager.createSound
        url: [streaming_url, client_params].join '?'

      active_track.play()
      trigger 'start'
      active_track

    stop: () ->
      if active_track
        active_track.stop()
        trigger 'stop'

      active_track = null

  Audio

]
