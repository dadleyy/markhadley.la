mh.config ["$routeProvider", ($routeProvider) ->

  api_home = "https://api.soundcloud.com"

  resolve = {}

  resolve.playlists = ["$q", "$http", "CONFIG", ($q, $http, CONFIG) ->
    {soundcloud} = CONFIG
    defferred = $q.defer()
    uri_path = [api_home, "users", soundcloud.user_id, "playlists.json"].join "/"
    query_parms = ["client_id", atob soundcloud.client_id].join "="

    finish = (response) ->
      playlists = response.data
      defferred.resolve playlists

    fail = (err) ->
      defferred.reject 404

    http_promise = $http.get [uri_path, query_parms].join("?")

    http_promise.then finish
      .catch fail

    defferred.promise
  ]

  resolve.colors = ["$q", "$http", "CONFIG", ($q, $http, CONFIG) ->
    {colors} = CONFIG

    unless colors.data_source
      return $q.resolve colors

    $http.get colors.data_source
      .then ({data}) -> $q.resolve data
  ]

  home = {resolve}

  home.templateUrl = "views.home"
  home.name        = "home"
  home.controller  = "HomeController"

  $routeProvider.when "/", home

]
