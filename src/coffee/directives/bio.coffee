mh.directive 'mhBio', ['$sce', ($sce) ->

  mhBio =
    replace: true
    templateUrl: 'directives.bio'
    scope:
      content: '='
      info: '='
    link: ($scope, $element, $attrs) ->
      console.log $scope.content

      $scope.safe = () ->
        $sce.trustAsHtml $scope.content


]
