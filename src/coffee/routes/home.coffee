mh.config ['$routeProvider', ($routeProvider) ->

  api_home = "https://api.soundcloud.com"

  $routeProvider.when '/',
    templateUrl: 'views.home'
    controller: 'HomeController'
    name: 'home'
    resolve:
      playlists: ['$q', '$http', 'SOUNDCLOUD_KEY', 'SOUNDCLOUD_USER', ($q, $http, SOUNDCLOUD_KEY, SOUNDCLOUD_USER) ->
        defferred = $q.defer()
        uri_path = [api_home, 'users', SOUNDCLOUD_USER, 'playlists.json'].join '/'
        query_parms = ['client_id', SOUNDCLOUD_KEY].join '='

        finish = (response) ->
          playlists = response.data
          defferred.resolve playlists

        fail = () ->

        http_promise = $http.get [uri_path, query_parms].join('?')
        http_promise.then finish, fail
        defferred.promise
      ]
      bio_content: ['$q', '$http', 'URLS', ($q, $http, URLS) ->
        defferred = $q.defer()
        content_url = [URLS.blog, 'page', 'content', '5429aaaa09203'].join '/'
        content_request = $http.get content_url

        receive = (response) ->
          defferred.resolve response.data

        content_request.then receive

        defferred
      ]
      bio_info: ['$q', '$http', 'URLS', ($q, $http, URLS) ->
        defferred = $q.defer()
        info_url = [URLS.blog, 'page', '5429aaaa09203'].join '/'
        info_request = $http.get info_url

        receive = (response) ->
          defferred.resolve response.data

        info_request.then receive

        defferred
      ]

]
