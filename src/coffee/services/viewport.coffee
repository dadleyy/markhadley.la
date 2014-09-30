mh.service 'Viewport', ['$window', '$rootScope', 'Loop', ($window, $rootScope, Loop) ->

  resize_loop_id = null
  listeners = []
  stop_timeout = null

  stopListening = () ->
    Loop.remove resize_loop_id
    resize_loop_id = null

  $window.onresize = () ->
    if resize_loop_id == null
      resize_loop_id = Loop.add update

    $window.clearTimeout stop_timeout
    stop_timeout = $window.setTimeout stopListening, 1000

  update = () ->
    width = $window.innerWidth
    height = $window.innerHeight
    listener width, height for listener in listeners
    $rootScope.$digest()

  Viewport =
    addListener: (fn) ->
      listeners.push fn
      fn $window.innerWidth, $window.innerHeight

]
