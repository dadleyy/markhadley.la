mh.controller 'BioController', ['$scope', '$sce', 'content', 'info', ($scope, $sce, content, info) ->

  $scope.content = $sce.trustAsHtml content
  $scope.info = info

]
