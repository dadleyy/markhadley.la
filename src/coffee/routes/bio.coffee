mh.config ['$routeProvider', ($routeProvider) ->

  $routeProvider.when '/bio',
    templateUrl: 'views.bio'
    controller: 'BioController'
    name: 'bio'
    resolve:
      content: ['$q', '$http', 'URLS', ($q, $http, URLS) ->
        defferred = $q.defer()
        content_url = [URLS.blog, 'page', 'content', '5429aaaa09203'].join '/'
        content_request = $http.get content_url

        receive = (response) ->
          defferred.resolve response.data

        content_request.then receive

        defferred.promise
      ]
      info: ['$q', '$http', 'URLS', ($q, $http, URLS) ->
        defferred = $q.defer()
        info_url = [URLS.blog, 'page', '5429aaaa09203'].join '/'
        info_request = $http.get info_url

        receive = (response) ->
          defferred.resolve response.data

        info_request.then receive

        defferred.promise
      ]

]
