mh.directive 'mhHeader', ['Loop', (Loop) ->

  SPEED = 20
    
  getTop = () ->
    if window.pageYOffset
      window.pageYOffset
    else
      document.documentElement.scrollTop

  body = document.body
  html = document.documentElement

  getMaxTop = () ->
    vals = [
      body.scrollHeight,
      body.offsetHeight,
      html.clientHeight,
      html.scrollHeight,
      html.offsetHeight
    ]
    height = Math.max.apply null, vals
    height - window.innerHeight

  mhHeader =
    replace: true
    templateUrl: 'directives.header'
    scope: {}
    link: ($scope, $element, $attrs) ->
      loop_id = null
      direction = 0

      update = () ->
        top = getTop()
        max_top = getMaxTop()
        direction *= 1.05
        next = top + direction
        scrollTo 0, next
        if next > max_top
          Loop.remove loop_id
        else if next < 0
          Loop.remove loop_id

      $scope.scroll = () ->
        above_half = getTop() < (getMaxTop() * 0.5)
        direction = if above_half then SPEED else -SPEED
        loop_id = Loop.add update


]
