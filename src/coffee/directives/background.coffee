mh.directive 'mhBackground', ['BACKGROUND', (BACKGROUND) ->

  mhBackground =
    replace: true
    templateUrl: 'directives.background'
    scope: {}
    link: ($scope, $element, $attrs) ->
      url_style = ['url(', BACKGROUND, ')'].join ''
      $element.css "background-image", url_style

]
