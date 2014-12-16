mh.directive 'mhWaveform', ['$http', 'Viewport', 'Waveform',  ($http, Viewport, Waveform) ->

  mhWaveform =
    replace: true
    templateUrl: 'directives.waveform'
    scope:
      track: '='
    link: ($scope, $element, $attrs) ->
      canvas = document.createElement 'canvas'
      context = canvas.getContext '2d'
      waveform_data = null
      waveform = new Waveform
        canvas: canvas
        innerColor: '#414141'
        
      width = 0
      height = 0

      receive = (response) ->
        received_data = response.data
        waveform.width = width
        waveform.height = height
        waveform.update
          data: received_data

      start = (evt, track) ->
        waveform_data = null
        waveform_url = track.waveform()
        data_request = $http.get "/api/waveform",
          params:
            url: waveform_url

        data_request.then receive

      resize = () ->
        width = $element[0].offsetWidth
        height = $element[0].offsetHeight

        waveform.width = width
        waveform.height = height

        canvas.width = width
        canvas.height = height

        waveform.redraw()

      Viewport.addListener resize
      $scope.$on 'playback_start', start
      $element.append canvas

]
