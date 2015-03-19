#= require line_chart

class @Brush
  constructor: (options={}) ->
    {@select}

class @Slider
  _new_handle = false
  constructor: (options={}) ->
    {@select, @legend} = options
    @boundaries = new Boundaries
      height: @legend.slider_value
      width: 50

    _new_handle = false

    @subscribers = []
    @subscribe(@legend)

    @domain = options.domain ? @defaultDomain()

    @axis = new Axis
      domain: @domain
      #orientation: "right"
      ticks: 0

    @svg = d3.select(@select).append("svg")
      .attr("width", @boundaries.width)
      .attr("height", @boundaries.height)

    @colorpicker = d3.select(@select).append("div")
      .attr("id", "colorpicker")
      .attr("style", "width: 200px; height: 150px")

    @slider = @svg.append("g")
      .attr("class","slider")
      .attr("width", @boundaries.width)

    @slideraxis = @slider.call(@axis.axis)
    @slideraxis.attr("transform", "translate(2,0)")

    @slider.on("mousedown", =>
      @newHandle()
      # console.log(_new_handle)
    ).on("mouseup", =>
      # console.log("mouseup")
      # console.log(_new_handle)
      # if _new_handle == true
        # console.log("Insert Handle!!")
    )

    @handles = []
    @ordered_handles = []

  defaultDomain: =>
    new Domain
      min: 0
      max: 1
      scaletype: "linear"
      height: @legend.slider_value
      # height: 20

  redrawSubscribers: =>
    for subscriber in @subscribers
      subscriber.redraw()


  subscribe: (subscriber) =>
    @subscribers.push(subscriber)

  addHandle: (options={}) =>
    _color = undefined # options.color ? new Color("black")
    _autocolor = options.autocolor ? false
    if _autocolor
      pos = @legend.slider_value - options.position
      _color = @getColorAt(pos / @legend.slider_value).toString()
    else 
      _color = options.color ? new Color("black")
    _handle = new Handle
      slider: @
      color: _color
    _handle.reposition(options.position) if options.position
    # _handle.changeColor(@getColorAt(_handle.value())) if _autocolor
    _handle.setDirection("left")
    @handles.push(_handle)
    @resort()
    @redrawSubscribers()


  removeHandle: (handle) =>
    array = []
    for _handle in @handles
      if handle != _handle
        array.push(_handle)
    $(handle.handle[0][0]).remove()
    @handles = array
    @resort()
    @redrawSubscribers()
    window.m.hist.render()

  resort: =>
    # @ordered_handles = @handles
    @handles.sort (a,b) =>
      d3.ascending(a.value(), b.value())

  getAllValues: =>
    _array = []
    for handle in @handles
      _array.push(handle.value())
    return _array

  getAllColors: =>
    _array = []
    for handle in @handles
      _array.push(handle.getColor())
    return _array

  getCompleteValueArray: =>
    _array = [0]
    _array.push(@getAllValues())
    _array.push(1)
    _array = [].concat.apply([], _array)
    new Float32Array(_array)

  getCompleteColorArray: =>
    _array = []
    _array.push([0,0,0,1])
    for handle in @handles
      _array.push(handle.getColorArray())
    _array.push([1,1,1,1])
    _array = [].concat.apply([], _array)
    _ret_array = new Float32Array(_array)
    return _ret_array


  getColorAt: (value) =>
    lowerVal = 0
    upperVal = 1
    colors = @getAllColors()
    lowerColor = new Color("black").color
    upperColor = new Color("white").color

    for val, i in @getAllValues()
      if val > value
        upperVal = val
        upperColor = colors[i]
        break
      else
        lowerVal = val
        lowerColor = colors[i]
    # console.log([lowerVal, upperVal])
    # console.log([lowerColor, upperColor])

    stepwidth = upperVal - lowerVal
    currentStep = (value - lowerVal) / stepwidth
    rWidth = upperColor.r - lowerColor.r
    gWidth = upperColor.g - lowerColor.g
    bWidth = upperColor.b - lowerColor.b
    r = lowerColor.r + currentStep * rWidth
    g = lowerColor.g + currentStep * gWidth
    b = lowerColor.b + currentStep * bWidth
    # console.log(r, g, b)
    # newcol = new Color({r: r, g: g, b: b})
    d3.rgb(r,g,b)



  newHandle: =>
    _new_handle = true

  noNewHandle: =>
    _new_handle = false




class @Handle
  _last_click = 0
  constructor: (options={}) ->
    {@slider, @domain, @overlay} = options
    _slider = @slider
    _last_click = 0

    _color_value = options.color ? "black"
    @color = new Color(_color_value)
    if @slider instanceof Slider
      _slider = @slider.slider
      @domain = @slider.domain
      @overlay = @slider.svg[0][0]

    _offset = 0
    _start = 0
    @brush = d3.svg.brush()
      .y(@domain.domain)
      .extent([0,0])
      .on("brushstart", =>
        _offset = @getPosition() - d3.mouse(@overlay)[1]
        _start = @getPosition()
        # @slider.noNewHandle()
        $(".picker").spectrum("hide")
      )
      .on("brush", =>
        @reposition(d3.mouse(@overlay)[1] + _offset) 
        #console.log(d3.mouse(@overlay))
        # @slider.noNewHandle()
        @slider.resort()
        @slider.redrawSubscribers()
      )
      .on("brushend", =>
        # marker didn't get moved, only clicked
        if @doubleClick(Date.now()) or @outOfRange()
          @slider.removeHandle(@)
          return
        d3.event.sourceEvent.preventDefault()
        if _start == @getPosition() 
          $(@picker).spectrum("show")
        @slider.resort()
        @slider.redrawSubscribers()
        window.m.hist.render()
      )

    @handle = _slider.append("polygon")
      .attr("class","handle")
      .attr("points", "0,-5 -5,5 5,5")
      .attr("fill","#000000")
      .attr("stroke", "#000000")
      # .attr("transform", =>
      #   "translate(0 ,20)"
      # )

    # @color = new Color("black")

    @picker = d3.select("#colorpicker")
      .append("div")
      .attr("class","picker")[0]

    $(@picker).spectrum({
      showPaletteOnly: true,
      togglePaletteOnly: true,
      color: @color.color.toString(),
      hideAfterPaletteSelect: true,
      # clickoutFiresChange: true,
      palette: [
        ["#000","#444","#666","#999","#ccc","#eee","#f3f3f3","#fff"],
        ["#f00","#f90","#ff0","#0f0","#0ff","#00f","#90f","#f0f"]
        # ["#f4cccc","#fce5cd","#fff2cc","#d9ead3","#d0e0e3","#cfe2f3","#d9d2e9","#ead1dc"],
        # ["#ea9999","#f9cb9c","#ffe599","#b6d7a8","#a2c4c9","#9fc5e8","#b4a7d6","#d5a6bd"],
        # ["#e06666","#f6b26b","#ffd966","#93c47d","#76a5af","#6fa8dc","#8e7cc3","#c27ba0"],
        # ["#c00","#e69138","#f1c232","#6aa84f","#45818e","#3d85c6","#674ea7","#a64d79"],
        # ["#900","#b45f06","#bf9000","#38761d","#134f5c","#0b5394","#351c75","#741b47"],
        # ["#600","#783f04","#7f6000","#274e13","#0c343d","#073763","#20124d","#4c1130"]
      ],
      change: (color) =>
        # @handle.attr("fill", color.toHexString())
        # @color.setColor(color.toHexString())
        # @slider.legend.redraw()
        @changeColor(color.toHexString())
    })

    @handle.call(@brush)
    @handle.attr("fill", @color.color.toString())

  getPosition: =>
    @brush.extent()[1]

  outOfRange: =>

    if @getPosition() < -1 or @getPosition() > @slider.domain.height + 1
      return true
    else 
      return false

  changeColor: (color) =>
    @handle.attr("fill", color)
    @color.setColor(color)
    @slider.redrawSubscribers()
    window.m.hist.render()

  setDirection: (direction) =>
    switch direction
      when "up" then @handle.attr("points", "0,-5 -5,5 5,5")
      when "down" then @handle.attr("points", "0,5 -5,-5 5,-5")
      when "left" then @handle.attr("points", "-5,0 5,-5 5,5")
      when "right" then @handle.attr("points", "5,0 -5,5 -5,-5")

  reposition: (pos) =>
    @brush.extent([pos, pos])
    console.log(@brush.extent())
    @handle.attr("transform", =>
      "translate(7," + pos + ")"
    )

  destroy: =>
    @slider.removeHandle(@)

  value: =>
    @domain.value_at(@getPosition())

  getColor: =>
    @color.getColor()

  getColorArray: (alpha = 1.0) =>
    _array = []
    _array.push(@color.color.r / 255)
    _array.push(@color.color.g / 255)
    _array.push(@color.color.b / 255)
    _array.push(alpha)
    return _array

  doubleClick: (time) =>
    timespan = time - _last_click
    if timespan < 330
      true
    else
      _last_click = time 
      false

