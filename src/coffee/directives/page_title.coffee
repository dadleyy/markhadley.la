mh.directive 'mhPageTitle', ['$rootScope', 'Analytics', ($rootScope, Analytics) ->

  default_title = 'Composer'

  mhPageTitle =
    scope: {}
    link: ($scope, $element, $attrs) ->
      update = (evt, route_event) ->
        route = route_event.$$route
        route_title = if route and route.title then route.title else default_title
        title = ['Mark Hadley', route_title].join ' | '
        $element.html title
        Analytics.track route.originalPath, route.title

      start = (evt, route_event) ->
        route = route_event.$$route
        if route
          Analytics.event 'routing', 'route_start', route.originalPath

      error = (evt, route_event) ->
        route = route_event.$$route
        if route
          Analytics.event 'routing', 'route_error', route.originalPath

      $rootScope.$on '$routeChangeStart', start
      $rootScope.$on '#routeChangeError', error
      $rootScope.$on '$routeChangeSuccess', update

]
