mh.directive 'mhPageTitle', ['$rootScope', 'Analaytics', ($rootScope, Analaytics) ->

  default_title = 'musician'

  mhPageTitle =
    scope: {}
    link: ($scope, $element, $attrs) ->
      update = (evt, route_event) ->
        route = route_event.$$route
        title = ['mark hadley', route.title || default_title].join ' | '
        $element.html title
        Analaytics.track route.originalPath, route.title

      start = (evt, route_event) ->
        route = route_event.$$route
        Analaytics.event 'routing', 'route_start', route.originalPath

      error = (evt, route_event) ->
        route = route_event.$$route
        Analaytics.event 'routing', 'route_error', route.originalPath

      $rootScope.$on '$routeChangeStart', start
      $rootScope.$on '#routeChangeError', error
      $rootScope.$on '$routeChangeSuccess', update

]
