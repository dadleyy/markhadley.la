mh = do () ->
  mh = angular.module "mh", ["ngRoute", "ngResource"]

  loaded_config = ({data: config}) ->
    mh.value "CONFIG", config
    angular.bootstrap document, ["mh"]

  failed_config = (err) ->
    console.error err

  injector = angular.injector ["ng"]
  http = injector.get "$http"

  http.get "/app.conf.json"
    .then loaded_config
    .catch failed_config

  mh
