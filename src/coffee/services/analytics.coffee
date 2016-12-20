mh.service "Analytics", ["CONFIG", (CONFIG) ->

  {google} = CONFIG

  ga "create", google.tracking, "auto"
  ga "send", "pageview"

  Analytics =

    track: (path, title) ->
      ga "send", "pageview",
        page: path,
        title: title
    
    log: () ->

    event: (category, action, data) ->
      ga "send", "event", category, action, data

  Analytics

]
