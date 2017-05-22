mh.service "Audio", ["$q", "Analytics", "Loop", "CONFIG", ($q, Analytics, Loop, {soundcloud}) ->

  SOUNDCLOUD_KEY = atob soundcloud.client_id

  active_track = null

  soundManager.setup
    debugMode: false

  trigger = (evt) ->
    fn() for fn in @listeners[evt]

  class Track

    constructor: (@track) ->
      client_params = ["client_id", SOUNDCLOUD_KEY].join "="
      @id = @track.id
      @playing = false
      @playback_loop = null
      @listeners =
        start: []
        stop: []
        playback: []
        pause: []
        finished: []

      _trigger = (args...) => trigger.apply(this, args)

      @sound = soundManager.createSound
        url: [@track.stream_url, client_params].join "?"
        onfinish: => _trigger "finished"

    position: () ->
      @sound.position

    duration: () ->
      @track.duration

    title: () ->
      @track.title

    waveform: () ->
      @track.waveform_url

    isPlaying: () ->
      @playing

    pause: () ->
      @playing = false
      active_track = null
      trigger.call @, "pause"
      @sound.stop()

    play: () ->
      @playing = true

      update = () =>
        trigger.call @, "playback"

      if active_track and active_track.id != @id
        active_track.stop()

      active_track = @

      @playback_loop = Loop.add update
      trigger.call @, "start"
      Analytics.event "audio", "playback:start", @track.title
      @sound.play()

    stop: () ->
      @playing = false
      Loop.remove @playback_loop
      trigger.call @, "stop"
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
