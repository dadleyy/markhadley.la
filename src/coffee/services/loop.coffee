mh.service 'Loop', ['$window', ($window) ->

  luid = do ->
    id = 0
    () ->
      id += 1
      id

  active_listeners = []
  running = false
  vendors = ['', 'ms', 'moz', 'webkit', 'o']

  request = (fn) ->
    $window.setTimeout fn, 33

  for vendor in vendors
    fn_name = vendor+'RequestAnimationFrame'
    fn_name = fn_name[0].toLowerCase() + fn_name.substr(1)
    if $window[fn_name]
      request = $window[fn_name]
      break

  run = () ->
    if active_listeners.length == 0
      running = false
    else
      for wrapper in active_listeners
        wrapper()

    if running
      request run

  Loop =

    add: (fn) ->
      wrapper = () ->
        fn()
      wrapper.uid = luid()
      active_listeners.push wrapper

      if !running
        running = true
        run()
      
      wrapper.uid

    remove: (id) ->
      for wrapper, indx in active_listeners
        if wrapper.uid == id
          active_listeners.splice indx, 1
          break

]
