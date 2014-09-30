mh.directive 'mhPlaylist', ['Viewport', 'Loop', (Viewport, Loop) ->

  mhPlaylist =
    replace: true
    templateUrl: 'directives.playlist'
    scope:
      playlist: '='
    link: ($scope, $element, $attrs) ->

]
