mh.config ['$routeProvider', ($routeProvider) ->

  api_home = "https://api.soundcloud.com"
  colors_sheet = "/api/content"

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
      about_page: ['$q', '$http', 'URLS', ($q, $http, URLS) ->
        defferred = $q.defer()

        content_url = [URLS.blog, 'pages'].join '/'
        content_params = ['filter[name]', 'about'].join '='

        content_request = $http.get [content_url, content_params].join('?')

        receive = (response) ->
          defferred.resolve response.data[0]

        content_request.then receive

        defferred.promise
      ]
      colors: ['$q', '$http', 'CONFIG', ($q, $http, CONFIG) ->
        defferred = $q.defer()

        colors_url = [colors_sheet, CONFIG.colors_sheet].join '/'

        colors_request = $http.get colors_url

        receive = (response) ->
          parsed = Papa.parse(response.data, {header: true})
          defferred.resolve parsed.data

        colors_request.then receive

        defferred.promise
      ]

]
