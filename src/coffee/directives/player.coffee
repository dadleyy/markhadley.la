mh.directive 'mhPlayer', ['Audio', (Audio) ->

  mhPlayer =
    replace: true
    templateUrl: 'directives.player'
    scope:
      track: '='
    link: ($scope, $element, $attrs) ->

]
