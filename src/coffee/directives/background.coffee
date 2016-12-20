mh.directive "mhBackground", ["CONFIG", ({background}) ->

  mhBackground =
    replace: true
    templateUrl: "directives.background"
    scope: {}
    link: ($scope, $element, $attrs) ->
      url_style = ["url(", background, ")"].join ""
      $element.css "background-image", url_style

]
