mh.config ['$routeProvider', ($routeProvider) ->

  api_home = "https://api.soundcloud.com"

  $routeProvider.when '/discography',
    templateUrl: 'views.discography'
    controller: 'DiscographyController'
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

]
