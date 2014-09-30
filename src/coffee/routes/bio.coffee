mh.config ['$routeProvider', ($routeProvider) ->

  $routeProvider.when '/bio',
    templateUrl: 'views.bio'
    controller: 'BioController'
    resolve:
      bioPage: ['$q', '$http', 'URLS', ($q, $http, URLS) ->
        defferred = $q.defer()
        content_url = [URLS.blog, 'page', 'content', '5429aaaa09203'].join '/'
        info_url = [URLS.blog, 'page', '5429aaaa09203'].join '/'

        info_request = $http.get info_url
        content_request = $http.get content_url

        defferred.promise
      ]

]
