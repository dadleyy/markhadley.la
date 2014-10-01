mh.directive 'mhPlaylist', ['Viewport', 'Loop', 'Audio', 'Drawing', 'COLORS', (Viewport, Loop, Audio, Drawing, COLORS) ->

  tof = (num) ->
    parseFloat num

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
      $scope.active = null
      d_el = d3.select($element[0]).select '.playlist-guts'
      svg = d_el.append 'svg'
      rings = []
      tracks = []
      arc_gen = null
      loop_id = null
      width = 100
      height = 100

      addTrack = (track, indx) ->
        grp = svg.append 'g'
        path = grp.append 'path'

        grp.attr 'data-track', track.title

        if COLORS.tracks[track.id]
          path.attr 'fill', COLORS.tracks[track.id]
        else if COLORS.playlists[$scope.playlist.id]
          playlist_colors = COLORS.playlists[$scope.playlist.id]
          color_indx = indx % playlist_colors.length
          path.attr 'fill', playlist_colors[indx % playlist_colors.length]
        else
          path.attr 'fill', '#ffffff'

        ring = new Drawing.Ring grp, path, randspeed(indx)
        instance = new Audio.Track track

        fat_gen = () ->
          arc_gen.fat track

        std_gen = () ->
          arc_gen.standard track

        play_gen = () ->
          arc_gen.playing track, instance.position()

        over = () ->
          unless instance.playing
            ring.setGen fat_gen

        out = () ->
          unless instance.playing
            ring.setGen std_gen

        clicked = () ->
          if !instance.playing
            instance.play()
          else
            instance.stop()

        playing = () ->
          ring.setGen play_gen
          ring.update()

        stopped = () ->
          ring.setGen std_gen

        ring
          .on 'mouseover', over
          .on 'mouseout', out
          .on 'click', clicked
          .setGen std_gen

        instance
          .on 'playback', playing
          .on 'stop', stopped

        rings.push ring
        tracks.push instance

      position = (ring, indx) ->
        ring.move width * 0.5, height * 0.5

        if !tracks[indx].playing
          ring.rotate SPIN_SPEED

        ring.update()

      resize = () ->
        width = $element[0].offsetWidth
        height = $element[0].offsetHeight

        svg.attr
          width: width
          height: height

        position ring, rindx for ring, rindx in rings

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

      arc_gen = Drawing.arcFactory $scope.playlist
      Viewport.addListener resize
      addTrack track, index for track, index in $scope.playlist.tracks
      resize()
      $scope.$on 'playlist_change', toggle

]
