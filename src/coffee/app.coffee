mh = do () ->
  mh = angular.module 'mh', ['ngRoute', 'ngResource']

  loaded_config = (response) ->
    data = response.data
    mh.value 'URLS', data.urls
    mh.value 'GOOGLE', data.google
    mh.value 'BACKGROUND', data.background
    mh.value 'COLORS', if data.colors then data.colors else {}

    if data.soundcloud and data.soundcloud.client_id
      client_id = atob data.soundcloud.client_id
      mh.value 'SOUNDCLOUD_KEY', client_id
      mh.value 'SOUNDCLOUD_USER', data.soundcloud.user_id

    angular.bootstrap document, ['mh']

  failed_config = () ->

  injector = angular.injector ['ng']
  http = injector.get '$http'
  http.get('/app.conf').then loaded_config, failed_config
  mh
