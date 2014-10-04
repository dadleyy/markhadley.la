mh.directive 'mhBio', ['$sce', ($sce) ->

  mhBio =
    replace: true
    templateUrl: 'directives.bio'
    scope:
      content: '='
      info: '='
    link: ($scope, $element, $attrs) ->
      $scope.safe = () ->
        $sce.trustAsHtml $scope.content


]
