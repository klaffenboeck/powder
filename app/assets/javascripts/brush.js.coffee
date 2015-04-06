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
      margin:
        top: 5
        bottom: 5

    _new_handle = false

    @subscribers = []
    @subscribe(@legend)

    @domain = options.domain ? @defaultDomain()
    # @legend_domain = @legendDomain()

    @axis = new Axis
      domain: @domain
      #orientation: "right"
      ticks: 0

    @scale = new Axis
      domain: @domain
      orientation: "left"

    @svg = d3.select(@select).append("svg")
      .attr("width", @boundaries.width)
      .attr("height", @boundaries.height + 14)
      .attr(
        "transform",
        "translate(0,7)"
      )


    @colorpicker = d3.select(@select).append("div")
      .attr("id", "colorpicker")
      .attr("style", "width: 200px; height: 150px")

    @slider = @svg.append("g")
      .attr("class","slider")
      .attr("width", @boundaries.width)


    @slideraxis = @slider.call(@axis.axis)
    @slideraxis.attr("transform", "translate(0,0)")



    @svg_scale = d3.select("#legend-scale").append("svg")
      .attr("width", 30)
      .attr("height", @boundaries.height + 14)
      .attr("transform", "translate(0, 7)")

    @sliderleft = @svg_scale.append("g")
      .attr("class", "sliderscale")
      .attr("width", @boundaries.width)

    @sliderscale = @sliderleft.call(@scale.axis)
    @sliderscale.attr("transform", "translate(30, 0)")





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

  # legendDomain: =>
  #   new Domain
  #     name: "legend-domain"
  #     range: [0.95, 1]
  #     height: @legend.slider_value
  #     scaletype: "linear"


  changeDomain: (vals) =>
    @domain.domain.domain(vals)
    @slider.call(@axis.axis)
    @sliderleft.call(@scale.axis)   
    window.m.selection_manager.smd.changeDomain(vals)
    window.m.selection_manager.current_smd.changeDomain(vals)
    @redrawSubscribers(vals)


  redrawSubscribers: (bounds = undefined) =>
    for subscriber in @subscribers
      subscriber.redraw(bounds)


  subscribe: (subscriber) =>
    @subscribers.push(subscriber)

  addHandle: (options={}) =>

    position = options.position if _.isNumber(options.position)
    position = @domain.domain(options.value) if _.isNumber(options.value)
    _autocolor = options.autocolor ? false
    if _autocolor
      pos = @legend.slider_value - position
      # stepwidth = upperVal - lowerVal
      # currentStep = (value - lowerVal) / stepwidth
      # rWidth = upperColor.r - lowerColor.r
      # r = lowerColor.r + currentStep * rWidth
      d = @domain.domain.domain()
      domainwidth = d[1] - d[0]
      stepwidth = domainwidth / @legend.slider_value
      inner_value = stepwidth * pos
      value = d[0] + inner_value
      _color = @getColorAt(value).toString()
    else 
      _color = options.color ? new Color("black")
    _handle = new Handle
      slider: @
      color: _color
    _handle.reposition(position) if position
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
    console.log(value)
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
  @qoi = undefined
  _first_brush = false
  _initialized_dialog = false
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
        $(".picker").spectrum("hide") if _initialized_dialog
        $("#batch-panel").dialog("close") if _initialized_dialog
      )
      .on("brush", =>
        @reposition(d3.mouse(@overlay)[1] + _offset) 
        @slider.resort()
        @slider.redrawSubscribers()
      )
      .on("brushend", =>
        # marker didn't get moved, only clicked
        _first_brush = true
        if @doubleClick(Date.now()) or @outOfRange()
          @slider.removeHandle(@)
          return
        d3.event.sourceEvent.preventDefault()
        window.m.complex_view_holder.prepareQOIs()
        if _start == @getPosition() 
          #console.log(@handle)
          #$(@picker).spectrum("show")
          #$(@picker2).spectrum()
          _initialized_dialog = true
          @getSpectrum()
          @qoi.cluster()
          window.m.complex_view_holder.getTiles()
          for cluster, i in @qoi.clusters
            window.m.complex_view_holder.setTilesForCluster(cluster)
            cluster.setHoverId(i + 1)
            # console.log(cluster.getHoverId())
            
          $("#visual-clusters").html(@qoi.toHtml())

          # not cleanly implemented, but for now its working (two loops needed, see before)
          window.m.selection_manager.resetClusters()
          for cluster, i in @qoi.clusters
            # console.log("cluster" + i)
            window.m.complex_view_holder.setHoverForCluster(cluster)
            window.m.selection_manager.addCluster(cluster)
          window.m.selection_manager.setupClusterListener()
          $("#batch-panel").dialog(
            closeOnEscape: true
            title: "Regions of interest" #"Range: " + @qoi.getRange("String")
            position: 
              my: "left top"
              at: "right+20 top-16"
              of: @handle[0]
          )
          $('#panel-colorpicker-wrapper').show()
        @slider.resort()
        @slider.redrawSubscribers()
        window.m.selection_manager.updateColorsInRunList();
        #window.m.hist.render()
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

    @picker2 = $('#panel-colorpicker')

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
        ["#f00","#f90","#ff0","#0f0","#0ff","#00f","#90f","#f0f"],
        ['rgb(118,42,131)','rgb(175,141,195)','rgb(231,212,232)','rgb(247,247,247)','rgb(217,240,211)','rgb(127,191,123)','rgb(27,120,55)']

      ],
      change: (color) =>
        # @handle.attr("fill", color.toHexString())
        # @color.setColor(color.toHexString())
        # @slider.legend.redraw()
        #console.log("CHANGING")
        @changeColor(color.toHexString())
    })

    @handle.call(@brush)
    @handle.attr("fill", @color.color.toString())

  getPosition: =>
    @brush.extent()[1]

  getSpectrum: =>
    $(@picker2).spectrum({
      showPaletteOnly: true,
      togglePaletteOnly: true,
      color: @color.color.toString(),
      hideAfterPaletteSelect: true,
      showInput: true,
      preferredFormat: "hex",
      clickoutFiresChange: true,
      palette: [
        #["#000","#444","#666","#999","#ccc","#eee","#f3f3f3","#fff"],
        #["#f00","#f90","#ff0","#0f0","#0ff","#00f","#90f","#f0f"],
        #['rgb(118,42,131)','rgb(175,141,195)','rgb(231,212,232)','rgb(247,247,247)','rgb(217,240,211)','rgb(127,191,123)','rgb(27,120,55)']
        ['rgb(178,24,43)','rgb(239,138,98)','rgb(253,219,199)','rgb(247,247,247)','rgb(209,229,240)','rgb(103,169,207)','rgb(33,102,172)'],
        ['rgb(254,229,217)','rgb(252,187,161)','rgb(252,146,114)','rgb(251,106,74)','rgb(239,59,44)','rgb(203,24,29)','rgb(153,0,13)'],
        #['rgb(254,237,222)','rgb(253,208,162)','rgb(253,174,107)','rgb(253,141,60)','rgb(241,105,19)','rgb(217,72,1)','rgb(140,45,4)'],
        ['rgb(239,243,255)','rgb(198,219,239)','rgb(158,202,225)','rgb(107,174,214)','rgb(66,146,198)','rgb(33,113,181)','rgb(8,69,148)'],
        ['rgb(237,248,233)','rgb(199,233,192)','rgb(161,217,155)','rgb(116,196,118)','rgb(65,171,93)','rgb(35,139,69)','rgb(0,90,50)'],
        ['rgb(247,247,247)','rgb(217,217,217)','rgb(189,189,189)','rgb(150,150,150)','rgb(115,115,115)','rgb(82,82,82)','rgb(37,37,37)']

      ],
      move: (color) =>
        # @handle.attr("fill", color.toHexString())
        # @color.setColor(color.toHexString())
        # @slider.legend.redraw()
        #console.log("CHANGING")
        @changeColor(color.toHexString())
      hide: (color) =>

        #console.log("CHANGING")
        @changeColor(color.toHexString())
    })

  outOfRange: =>

    if @getPosition() < -1 or @getPosition() > @slider.domain.height + 1
      return true
    else 
      return false

  changeColor: (color) =>
    @handle.attr("fill", color)
    @color.setColor(color)
    @slider.redrawSubscribers()
    window.m.selection_manager.updateColorsInRunList()
    #window.m.hist.render()

  setDirection: (direction) =>
    switch direction
      when "up" then @handle.attr("points", "0,-5 -5,5 5,5")
      when "down" then @handle.attr("points", "0,5 -5,-5 5,-5")
      when "left" then @handle.attr("points", "-5,0 5,-5 5,5")
      when "right" then @handle.attr("points", "5,0 -5,5 -5,-5")

  reposition: (pos) =>
    @brush.extent([pos, pos])
    #console.log(@brush.extent())
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
  setQOI: (qoi) =>
    @qoi = qoi

  getQOI: =>
    return @qoi

