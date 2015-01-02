#= require line_chart

class @Brush
  constructor: (options={}) ->
    {@select}

class @Slider
  _new_handle = false
  constructor: (options={}) ->
    {@select} = options
    @boundaries = new Boundaries
      width: 500
      height: 100

    _new_handle = false

    @domain = options.domain ? @defaultDomain()

    @axis = new Axis
      domain: @domain
      ticks: 0

    @svg = d3.select(@select).append("svg")
      .attr("width", @boundaries.width)
      .attr("height", @boundaries.height)

    @colorpicker = d3.select(@select).append("div")
      .attr("id", "colorpicker")
      .attr("style", "width: 200px; height: 200px")

    @slider = @svg.append("g")
      .attr("class","slider")
      .attr("width", @boundaries.width)

    @slideraxis = @slider.call(@axis.axis)
    @slideraxis.attr("transform", "translate(0,20)")

    @slider.on("mousedown", =>
      @newHandle()
      console.log(_new_handle)
    ).on("mouseup", =>
      console.log("mouseup")
      console.log(_new_handle)
      if _new_handle == true
        console.log("Insert Handle!!")
    )


    @handles = []
    @ordered_handles = []

  defaultDomain: =>
    new Domain
      min: 0
      max: 1
      scaletype: "linear"
      width: 500
      # height: 20

  addHandle: =>
    _handle = new Handle
      slider: @
      # slider: @slider
      # domain: @domain
      # overlay: @svg[0][0]
    @handles.push(_handle)

  removeHandle: (handle) =>
    array = []
    for _handle in @handles
      if handle != _handle
        array.push(_handle)
    $(handle.handle[0][0]).remove()
    @handles = array

  resort: =>
    # @ordered_handles = @handles
    @handles.sort (a,b) =>
      d3.ascending(a.value(), b.value())

  getAllValues: =>
    _array = []
    for handle in @handles
      _array.push(handle.value())
    return _array

  newHandle: =>
    _new_handle = true

  noNewHandle: =>
    _new_handle = false


class @Handle
  constructor: (options={}) ->
    {@slider, @domain, @overlay} = options
    _slider = @slider
    if @slider instanceof Slider
      _slider = @slider.slider
      @domain = @slider.domain
      @overlay = @slider.svg[0][0]

    _offset = 0
    _start = 0
    @brush = d3.svg.brush()
      .x(@domain.domain)
      .extent([0,0])
      .on("brushstart", =>
        _offset = @getPosition() - d3.mouse(@overlay)[0]
        _start = @getPosition()
        @slider.noNewHandle()
        $(".picker").spectrum("hide")
      )
      .on("brush", =>
        @reposition(d3.mouse(@overlay)[0] + _offset) 
        @slider.noNewHandle()
      )
      .on("brushend", =>
        # marker didn't get moved, only clicked
        d3.event.sourceEvent.preventDefault()
        if _start == @getPosition() 
          $(@picker).spectrum("show")
        @slider.resort()
      )

    @handle = _slider.append("polygon")
      .attr("class","handle")
      .attr("points", "0,-5 -5,5 5,5")
      .attr("fill","#000000")
      .attr("stroke", "#000000")
      # .attr("transform", =>
      #   "translate(0 ,20)"
      # )

    @picker = d3.select("#colorpicker")
      .append("div")
      .attr("class","picker")[0]

    $(@picker).spectrum({
      showPaletteOnly: true,
      togglePaletteOnly: true,
      palette: [
        ["#000","#444","#666","#999","#ccc","#eee","#f3f3f3","#fff"],
        ["#f00","#f90","#ff0","#0f0","#0ff","#00f","#90f","#f0f"],
        ["#f4cccc","#fce5cd","#fff2cc","#d9ead3","#d0e0e3","#cfe2f3","#d9d2e9","#ead1dc"],
        ["#ea9999","#f9cb9c","#ffe599","#b6d7a8","#a2c4c9","#9fc5e8","#b4a7d6","#d5a6bd"],
        ["#e06666","#f6b26b","#ffd966","#93c47d","#76a5af","#6fa8dc","#8e7cc3","#c27ba0"],
        ["#c00","#e69138","#f1c232","#6aa84f","#45818e","#3d85c6","#674ea7","#a64d79"],
        ["#900","#b45f06","#bf9000","#38761d","#134f5c","#0b5394","#351c75","#741b47"],
        ["#600","#783f04","#7f6000","#274e13","#0c343d","#073763","#20124d","#4c1130"]
      ],
      change: (color) =>
        @handle.attr("fill", color.toHexString())
    })

    @handle.call(@brush)


  getPosition: =>
    @brush.extent()[0]

  setDirection: (direction) =>
    switch direction
      when "up" then @handle.attr("points", "0,-5 -5,5 5,5")
      when "down" then @handle.attr("points", "0,5 -5,-5 5,-5")
      when "left" then @handle.attr("points", "-5,0 5,-5 5,5")
      when "right" then @handle.attr("points", "5,0 -5,5 -5,-5")

  reposition: (pos) =>
    @brush.extent([pos, pos])
    @handle.attr("transform", =>
      "translate(" + pos + ",0)"
    )

  destroy: =>
    @slider.removeHandle(@)

  value: =>
    @domain.value_at(@getPosition())
