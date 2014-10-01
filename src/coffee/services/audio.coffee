mh.service 'Audio', ['$q', 'Loop', 'SOUNDCLOUD_KEY', ($q, Loop, SOUNDCLOUD_KEY) ->

  active_track = null

  trigger = (evt) ->
    fn() for fn in @listeners[evt]

  class Track

    constructor: (@track) ->
      client_params = ['client_id', SOUNDCLOUD_KEY].join '='
      @playing = false
      @playback_loop = null
      @listeners =
        start: []
        stop: []
        playback: []

      @sound = soundManager.createSound
        url: [@track.stream_url, client_params].join '?'

    position: () ->
      @sound.position

    play: () ->
      @playing = true

      update = () =>
        trigger.call @, 'playback'

      @playback_loop = Loop.add update
      active_track = @
      @sound.play()

    stop: () ->
      @playing = false
      Loop.remove @playback_loop
      trigger.call @, 'stop'
      @sound.stop()

    on: (evt, fn) ->
      if @listeners[evt] and angular.isFunction(fn)
        @listeners[evt].push fn
      @

  Audio =

    stop: () ->
      if active_track
        active_track.stop()

  Audio.Track = Track

  Audio

]
