mh.directive 'mhPlaylist', [() ->

  mhPlaylist =
    replace: true
    templateUrl: 'directives.playlist'
    scope:
      playlist: '='
    link: ($scope, $element, $attrs) ->

]
