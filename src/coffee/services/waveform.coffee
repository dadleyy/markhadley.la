mh.service 'Waveform', [() ->

  class Waveform

    constructor: (options) ->
      @container = options.container
      @canvas = options.canvas
      @data = options.data || []
      @outerColor = options.outerColor || "transparent"
      @innerColor = options.innerColor || "#FFFFFF"
      @interpolate = true
      @interpolate = false if options.interpolate == false
      @patchCanvasForIE(@canvas)
      @context = @canvas.getContext("2d")

    setData: (data) ->
      @data = data

    setDataInterpolated: (data) ->
      @setData @interpolateArray(data, @width)

    setDataCropped: (data) ->
      @setData @expandArray(data, @width)

    update: (options) ->
      if options.interpolate?
        @interpolate = options.interpolate
      if @interpolate == false
        @setDataCropped(options.data)
      else
        @setDataInterpolated(options.data)
      @redraw()

    redraw: () =>
      @clear()
      @context.fillStyle = @innerColor
      console.log @data
      middle = @height / 2
      i = 0
      for d in @data
        t = @width / @data.length
        @context.clearRect t*i, middle - middle * d, t, (middle * d * 2)
        @context.fillRect t*i, middle - middle * d, t, middle * d * 2
        i++

    clear: ->
      @context.fillStyle = @outerColor
      @context.clearRect(0, 0, @width, @height)
      @context.fillRect(0, 0,  @width, @height)

    patchCanvasForIE: (canvas) ->
      if typeof window.G_vmlCanvasManager != "undefined"
       canvas = window.G_vmlCanvasManager.initElement(canvas)
       oldGetContext = canvas.getContext
       canvas.getContext = (a) ->
         ctx = oldGetContext.apply(canvas, arguments)
         canvas.getContext = oldGetContext
         ctx

    expandArray: (data, limit, defaultValue=0.0) ->
      newData = []
      if data.length > limit
        newData = data.slice(data.length - limit, data.length)
      else
        for i in [0..limit-1]
          newData[i] = data[i] || defaultValue
      newData

    linearInterpolate: (before, after, atPoint) ->
      before + (after - before) * atPoint

    interpolateArray: (data, fitCount) ->
      newData = new Array()
      springFactor = new Number((data.length - 1) / (fitCount - 1))
      newData[0] = data[0]
      i = 1

      while i < fitCount - 1
        tmp = i * springFactor
        before = new Number(Math.floor(tmp)).toFixed()
        after = new Number(Math.ceil(tmp)).toFixed()
        atPoint = tmp - before
        newData[i] = @linearInterpolate(data[before], data[after], atPoint)
        i++
      newData[fitCount - 1] = data[data.length - 1]
      newData

  Waveform

]
