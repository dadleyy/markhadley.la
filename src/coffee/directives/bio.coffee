mh.directive 'mhBio', ['$sce', ($sce) ->

  mhBio =
    replace: true
    templateUrl: 'directives.bio'
    scope:
      page: '='
    link: ($scope, $element, $attrs) ->
      $scope.safe = () ->
        $sce.trustAsHtml $scope.page.content


]
