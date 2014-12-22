#= require estimation_function

class @Chart
  @name = "unspecified"

  addLine: (line) =>
    @display.addLine(line)

  drawLines: =>
    @display.drawLines()

  drawLine: (line, dur) =>
    @display.drawLine(line, dur)

  getLines: =>
    @display.lines

class @LineChart extends Chart
  constructor: (options={}) ->
    boundaries = new Boundaries
      margin:
        top: 10
        right: 10
        bottom: 30
        left: 50
      total_width: 640
      total_height: 380
    @stepsX = options.stepsX ? data_angles
    @domainX = new Domain
      range: data_angles
      width: boundaries.width
    @domainY = new Domain
      range: measured_points
      height: boundaries.height
    axisX = new Axis(
      domain: @domainX)
    axisY = new Axis({domain: @domainY})
    @display = new Display
      select: "#detailview-1 .main"
      boundaries: boundaries
      xAxis: axisX
      yAxis: axisY
      name: "mainview"
    @lines = []


class @NavChart extends Chart
  constructor: (options) ->
    {@ticks, @boundaries, @domain, @quality, @name} = options
    @set_default_boundaries() if not @boundaries
    @calc_ticks() if not @ticks
    @axisX = new Axis({domain: @domain, ticks: @ticks})
    @axisY = new KAxis({domain: @quality})
    @display = new Display
      select: "#navigation"
      boundaries: @boundaries
      xAxis: @axisX
      yAxis: @axisY
      name: @name
    # @domain.rangeband.on("mousemove", ->
    #   console.log(d3.mouse(this))
    # )
    @_current_position = options.startposition ? 10
    @current_x_value = @currX   #alias function
    @_x_values = @get_all_x_values(10)
    svg = d3.select("#navigation").selectAll("." + @name)
    svg.append("text")
      .data([@name])
      .attr("y", @boundaries.height + 50)
      .attr("x", @boundaries.total_width / 2)
      .text( (d) ->
        d
      )

  set_default_boundaries: =>
    @boundaries = new Boundaries
      width: 100
      height: 100
      margin:
        bottom: 10
        left: 60
        top: 10
        right: 20

  calc_ticks: =>
    
    r = @domain.range
    t = "a" + r[0] + r[1] # convert to text and get length of text
    l = t.length - 1
    lt = 11 - l

    @ticks = if lt > 2 then lt else 2
    console.log(t)

  current_position: (position = null) =>
    return @_current_position if position == null
    @_current_position = position

  currX: (pos = null) =>
    position = pos ? @current_position()
    @domain.value_at(position)

  get_all_x_values: =>
    @_x_values ? @domain.width_to_values(10)

  mousedown: (d,i) ->
    _overlay = @display.overlay[0][0]
    @current_position(d3.mouse(_overlay)[0])
    console.log(@current_position())

  mouseover: ->
    _overlay = @display.overlay[0][0]
    return d3.mouse(_overlay)[0]
    #@current_hover_position()


class @Domain
  constructor: (options={}) ->
    {@min, @max, @scaletype, @order} = options
    @name = options.name ? ""
    @range = options.range ? [@min, @max]
    @width = options.width ? 0
    @height = options.height ? 0
    @setup()

  setup: =>
    scaledefault = if @width then "linear" else "log"
    scaletyp = @scaletype ? scaledefault
    scale = d3.scale[scaletyp]().clamp(true)
    scale.base(10) if scaletyp == "log"
    @rangeband = scale.range([@height, @width])
    _range = d3.extent(@range)
    _range = [_range[1], _range[0]] if @order == "desc"
    @domain = @rangeband.domain(_range)
        

  orientation: =>
    if @height then "left" else "bottom"

  value_at: (position) =>
    @rangeband.invert(position)

  width_to_values: (modulo = 1)=>
    _values = []
    for i in [0..@width]
      if i % modulo == 0
        _values.push(@value_at(i))
    return _values


class @Boundaries
  constructor: (options={}) ->
    {@total_width, @total_height, @width, @height} = options
    @margin = options.margin ? {}
    @margin.top ?= 0
    @margin.bottom ?= 0
    @margin.left ?= 0
    @margin.right ?= 0
    @width ?= @total_width - @margin.left - @margin.right
    @height ?= @total_height - @margin.bottom - @margin.top
    @total_width ?= @width + @margin.left + @margin.right
    @total_height ?= @height + @margin.bottom + @margin.top



class @Axis
  constructor: (options={}) ->
    {@domain} = options
    @ticks = options.ticks ? 5
    @orientation = options.orientation ? @domain.orientation()
    @setup()

  setup: =>
    @axis =
      d3.svg.axis()
        .scale(@domain.domain)
        .ticks(@ticks)
        .orient(@orientation)
        .tickFormat(@k_format);

  value_at: (position) =>
    @domain.value_at(position)


class @KAxis extends Axis
  constructor: (options={}) ->
    super(options)
    @k_format = d3.format("s")
    @axis.tickFormat(@k_format)




class @Display
  constructor: (options={}) ->
    {@select, @boundaries, @xAxis, @yAxis} = options
    @name = options.name ? "undeclared"
    @lines = {}
    @setup()
    @create()
    
  setup: ->
    b = @boundaries
    @svg = d3.select(@select).append("svg")
    @view =
      @svg.attr("width", b.total_width)
      .attr("height", b.total_height)
      .attr("class", @name)
      .append("g")
      .attr(
        "transform",
        "translate(" +
        b.margin.left + "," +
        b.margin.top + ")");

    @overlay =
      @svg.append("rect")
        .attr("class", "overlay")
        .attr("width", b.width)
        .attr("height", b.height)
        .attr(
          "transform",
          "translate(" +
          b.margin.left + "," +
          b.margin.top + ")");


    # _overlay = @overlay
    # @overlay.on("mousedown", @track_mouse)
    # _overlay.on("mouseup", @stop_tracking)
    # d3.select(window).on("mouseup", ->
    #   _overlay.on("mousemove", null)
    # )
    @brush = d3.svg.brush()
      .x(@xAxis.domain.rangeband)
      .extent([0,0])
      .on("brush", ->
        console.log("brushed")
      )

  create: =>
    @view.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + @boundaries.height + ")")
      .call(@xAxis.axis);


    @view.append("g")
      .attr("class", "y axis")
      .call(@yAxis.axis);

  track_mouse: (value) =>
    _axis = @xAxis
    # @overlay.on("mousemove", ->
    #   console.log("display")
    #   console.log(this)
    #   # value = d3.mouse(this)[0]s
    #   # console.log(value)
    #   # console.log("outside")
    #   # return
    # )


  stop_tracking: =>
    @overlay.on("mousemove", null)

  addLine: (line) =>
    @lines[line.name] = line

  drawLines: =>
    keys = Object.keys(@lines)
    for key, index in keys
      line = @lines[key]
      @drawLine(line)

  drawLine: (line, dur = 750) =>
    return_function = (d) ->
      line.line(d)
    base =
      @view.selectAll("." + line.name)
      .data(new Array(line.valuesY) )

    base.enter()
      .append("g")
      .attr("class", line.name)
      .append("path")

      .attr("class", line.name + "-line line")
      .attr("stroke", line.color)
      .attr("d", return_function)
      .attr("stroke", line.color.color)

    @view.selectAll(line.fullClassSpecifier())
      .data(new Array(line.valuesY))
      .transition().delay(1).duration(dur)
      .style("opacity", line._opacity())
      .attr("d", return_function)

  removeLine: (line) =>
    @view.selectAll("." + line.name)
    .data([]).exit()
    .transition().delay(0).duration(500)
    .style("opacity", 0)
    .remove()



class @Line
  constructor: (options={}) ->
    {@name, @valuesX, @valuesY, @domainX, @domainY} = options
    @_show = options.show ? !options.hide ? true
    @interpolation = options.interpolation ? "basis"
    @color = options.color ? new Color("black")
    @setup()

  setup: =>
    funcX = (d,i) ->
      @domainX.domain(@valuesX[i])
    funcY = (d,i) ->
      @domainY.domain(@valuesY[i])
    @line =
      d3.svg.line()
        .interpolate("basis")
        .x(funcX)
        .y(funcY)

  className: =>
    "." + @name

  classNameLine: =>
    @className() + "-line"

  fullClassSpecifier: =>
    @className() + " " + @classNameLine()

  @difference: (line1, line2, with_offset = true) ->
    return "doesn't match" if line1.length != line2.length
    values1 = line1.valuesY
    values2 = line2.valuesY
   
    newValues = []
    for value, index in line1.valuesY
      newValues.push(Math.abs(value - values2[index]))
    newValues

  setDifference: (line1, line2, with_offset = true) =>
    diff = Line.difference(line1, line2, with_offset)
    @valuesY = diff

  show: =>
    @_show = true

  hide: =>
    @_show = false
    true

  toggle: =>
    @_show = !@_show

  visible: (boolean = null) =>
    return @_show if boolean == null
    @_show = boolean

  muted: =>
    !@_show

  _opacity: =>
    switch @_show
      when true then 1
      when false then 0

class @DiffLine extends Line
  constructor: (options={}) ->
    super(options)
    @line1 = options.line1
    @line2 = options.line2
    #@valuesY = @calcDifference

  setDifference: (line1, line2, with_offset = true) =>
    diff = DiffLine.difference(line1, line2, with_offset)
    @valuesY = diff

  @difference: (line1, line2, with_offset = true) ->
    return "doesn't match" if line1.length != line2.length
    values1 = line1.valuesY
    values2 = line2.valuesY
   
    newValues = []
    for value, index in line1.valuesY
      newValues.push(Math.abs(value - values2[index]))
    newValues

  calcDifference: =>
    @setDifference(@line1, @line2)


class @EstLine extends Line
  constructor: (options = {}) ->
    super(options)
    @key = options.key

class @Color
  constructor: (options={}) ->
    @color = @getColor(options) if typeof options == "string"
    @color = @getColor(options.color) if typeof options == "object"

  getColor: (string) ->
    d3.rgb(string)





