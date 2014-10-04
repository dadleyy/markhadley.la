mh.service 'Analytics', ['GOOGLE', (GOOGLE) ->

  ga 'create', GOOGLE.tracking, 'auto'
  ga 'send', 'pageview'

  Analytics =

    track: (path, title) ->
      ga 'send', 'pageview',
        page: path,
        title: title
    
    log: () ->

    event: (category, action, data) ->
      ga 'send', 'event', category, action, data

  Analytics

]
