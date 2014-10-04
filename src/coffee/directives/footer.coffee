mh.directive 'mhFooter', ['$rootScope', ($rootScope) ->

  mhFooter =
    replace: true
    templateUrl: 'directives.footer'
    scope: {}
    link: ($scope, $element, $attrs) ->
      $scope.active = false

      update = (evt, route_info) ->
        route = route_info.$$route

        if route
          $scope.active = route.name

      $rootScope.$on '$routeChangeStart', update

]
