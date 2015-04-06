#= require estimation_function

class @Chart
  @name = "unspecified"
  _blockCounter = 0

  addLine: (line) =>
    @display.addLine(line)

  drawLines: =>
    @display.drawLines()

  drawLine: (line, dur) =>
    @display.drawLine(line, dur)

  getLines: =>
    @display.lines

  addBlock: (block) =>
    @display.addBlock(block)

  drawBlocks: =>
    @display.drawBlocks()

  removeBlocks: =>
    @display.removeBlocks()

  checkBrush: =>
    extent = @brush.extent()
    return false if extent[0][0] == extent[1][0] or extent[0][1] == extent[1][1] 
    return true

  createBlock: (params) =>
    valuesX = [params[0][0], params[1][0]]
    valuesY = [params[0][1], params[1][1]]
    block = new Block({domainX: @domainX, domainY: @domainY, valuesX: valuesX, valuesY: valuesY, name: "block" + _blockCounter})
    @addBlock(block)
    _blockCounter += 1
    @drawBlocks()
    window.m.selection_manager.addBlock(block)
    @brush.extent([[0,0],[0,0]])
    @display.svg_brush
      .call(@brush)
    return block

  createCurrentBlock: =>
    @createBlock(@brush.extent())



class @LineChart extends Chart
  constructor: (options={}) ->
    boundaries = new Boundaries
      margin:
        top: 10
        right: 10
        bottom: 30
        left: 50
      total_width: 540
      total_height: 320
    @stepsX = options.stepsX ? data_angles
    @domainX = new Domain
      range: @stepsX
      width: boundaries.width
    @domainY = new Domain
      range: measured_points
      height: boundaries.height
    axisX = new Axis(
      domain: @domainX)
    axisY = new KAxis({domain: @domainY})
    @display = new BrushDisplay
      select: "#detailview-1 .main"
      boundaries: boundaries
      xAxis: axisX
      yAxis: axisY
      name: "mainview"
    @lines = []

    @brush = d3.svg.brush()
      .x(@domainX.domain)
      .y(@domainY.domain)
      .extent([[0,0],[0,0]])
      .on("brush", =>
        @brush.extent()
      )
      .on("brushend", =>
        console.log(@brush.extent())
        if @checkBrush()
          $(".set-exclude").removeClass("disabled")
        else
          $(".set-exclude").addClass("disabled")

      )

    #@display.view.call(@brush)
    @display.svg_brush
      .call(@brush)


class @ErrorChart extends Chart
  _bottom = null
  _top = null
  constructor: (options={}) ->
    @_linelist = []
    boundaries = new Boundaries
      margin:
        top: 10
        right: 10
        bottom: 30
        left: 50
      total_width: 540
      total_height: 260
    @stepsX = options.stepsX ? data_angles
    @domainX = new Domain
      range: @stepsX
      width: boundaries.width
    @domainY = new Domain
      range: measured_points
      height: boundaries.height
    axisX = new Axis(
      domain: @domainX)
    axisY = new KAxis({domain: @domainY, ticks: 3})
    @display = new BrushDisplay
      select: "#detailview-1 .error"
      boundaries: boundaries
      xAxis: axisX
      yAxis: axisY
      name: "errorview"
    @lines = []
    @_current_extent = 

    _bottom = @domainY.getMin()
    _top = @domainY.getMax()

    @brush = d3.svg.brush()
      .x(@domainX.domain)
      .y(@domainY.domain)
      .extent([[0,_bottom],[0,_top]])
      .on("brushstart", =>
        brush = @brush.extent()
        _bottom = @domainY.getMin()
        _top = @domainY.getMax()
        @brush.extent([[brush[0][0], _bottom], [brush[1][0], _top] ])
        @display.svg_brush
          .call(@brush)
      )
      .on("brush", =>
        brush = @brush.extent()
        @brush.extent([[brush[0][0], _bottom], [brush[1][0], _top] ])
        @display.svg_brush
          .call(@brush)

      )
      .on("brushend", =>
        @setCurrentExtent(@brush.extent())
        @display.svg_brush
          .call(@brush)
      )

    @display.svg_brush
      .call(@brush)

  createLine: (name, values) =>
    line = new ErrorLine
      name: name
      domainX: @domainX
      domainY: @domainY
      valuesX: window.m.data_angles.angles
      valuesY: values
      color: window.m.red

    @_linelist.push(line)
    @display.addLine(line)

  removeAllLines: =>
    @display.removeAllLines()

  setCurrentExtent: (extent) =>
    @_current_extent = [extent[0][0], extent[1][0]]

  getCurrentExtent: =>
    @_current_extent


  drawExtentManually: (left, right) =>
    if left.constructor == Array
      right = left[1]
      left  = left[0]
    _bottom = @domainY.getMin()
    _top = @domainY.getMax()
    extent = [[left, _bottom], [right, _top]]
    @brush.extent(extent)
    @setCurrentExtent(extent)
    @display.svg_brush.call(@brush)
  





class @NavChart extends Chart
  constructor: (options) ->
    {@ticks, @boundaries, @domain, @quality, @quality_axis, @name} = options
    @set_default_boundaries() if not @boundaries
    @calc_ticks() if not @ticks
    @axisX = new Axis({domain: @domain, ticks: @ticks})
    @axisY = new Axis({domain: @quality_axis})
    @display = new NavDisplay
      select: "#navigation"
      boundaries: @boundaries
      xAxis: @axisX
      yAxis: @axisY
      name: @name

    @_current_position = options.startposition ? 10
    @current_x_value = @currX   #alias function
    @_x_values = @get_all_x_values(10)
    svg = d3.select("#navigation").selectAll("." + @name)
    svg.append("text")
      .data([@name])
      # .attr("y", @boundaries.height + 50)
      .attr("y", 25)
      # .attr("x", @boundaries.total_width / 2)
      .attr("x", 35)
      .text( (d) ->
        d
      )

  set_default_boundaries: =>
    @boundaries = new Boundaries
      width: 100
      height: 100
      margin:
        bottom: 10
        left: 40
        top: 30
        right: 10

  calc_ticks: =>
    # r = @domain.range
    # t = "a" + r[0] + r[1] # convert to text and get length of text
    # l = t.length - 1
    # lt = 11 - l

    # @ticks = if lt > 2 then lt else 2
    @ticks = 2


  current_position: (position = null) =>
    return @_current_position if position == null
    @_current_position = position

  set_current_position: (position) =>
    @_current_position = position

  set_position_from_value: (value) =>
    _pos = @domain.rangeband(value)
    @set_current_position(_pos)

  currX: (pos = null) =>
    position = pos ? @current_position()
    @domain.value_at(position)

  get_all_x_values: =>
    @_x_values ? @domain.width_to_values(5)

  mousedown: (d,i) ->
    _overlay = @display.overlay[0][0]
    @current_position(d3.mouse(_overlay)[0])
    # console.log(@current_position())

  mouseover: ->
    _overlay = @display.overlay[0][0]
    return d3.mouse(_overlay)[0]

  drawNavBar: (barname = "-navbar") =>
    _bar = @getLines()[@name + barname]
    _bar.setPosition(@currX())
    @drawLine(_bar)

  drawEstNavBar: (position, barname = "-navbar-preview") =>
    _bar = @getLines()[@name + barname]
    _bar.setPosition(position)
    @drawLine(_bar, 0)


class @MiniChart extends Chart
  constructor: (options={}) ->
    {@boundaries, @domainX, @domainY, @axisX, @axisY, @select} = options
    @display = new BaseDisplay
      boundaries: @boundaries
      xAxis: @axisX
      yAxis: @axisY
      select: @select


class @InteractiveMiniChart extends MiniChart
  constructor: (options={}) ->
    super(options)
    @display.overlay.on("mouseover", (d) =>
      window.m.navigation.show_preview_lines()
      window.m.navigation.estimate_preview(d.input_params)
      # console.log(d)
    ).on("mouseout", (d) =>
      window.m.navigation.hide_preview_lines()
    ).on("mousedown", (d) =>
      window.m.updateLineChart(d)
      window.m.navigation.set_current_x_values(d.input_params)
      # console.log(window.m.navigation.current_x_values())
      window.m.navigation.estimate_all_lines()
    )


class @Domain
  # scaletyp = undefined
  constructor: (options={}) ->
    {@min, @max, @scaletype, @order} = options
    @name = options.name ? ""
    @range = options.range ? [@min, @max]
    @width = options.width ? 0
    @height = options.height ? 0
    @setup()
    @_scaletyp

  setup: =>
    scaledefault = if @width then "linear" else "log"
    @_scaletyp = @scaletype ? scaledefault
    scale = d3.scale[@_scaletyp]().clamp(true)
    scale.base(10) if @_scaletyp == "log"
    @scale = scale
    @rangeband = scale.range([@height, @width])
    _range = d3.extent(@range)
    _range = [_range[1], _range[0]] if @order == "desc"
    @domain = @rangeband.domain(_range)
        

  orientation: =>
    if @height then "left" else "bottom"

  value_at: (position) =>
    @rangeband.invert(position)

  position_for: (value) =>
    @rangeband(value)

  width_to_values: (modulo = 1)=>
    _values = []
    for i in [0..@width]
      if i % modulo == 0
        _values.push(@value_at(i))
    return _values

  minVal: =>
    @range[0]

  maxVal: =>
    @range[1]

  getScaleType: =>
    return @_scaletyp

  getScale: =>
    return @scale

  getMin: =>
    @domain.domain()[0]

  getMax: =>
    @domain.domain()[1]

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

class @DisplayAxis


class @BaseDisplay
  constructor: (options={}) ->
    {@select, @boundaries, @xAxis, @yAxis} = options
    @name = options.name ? "undeclared"
    @lines = {}
    @blocks = {}
    @setup()

    
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

  drawAxis: =>
    @drawAxisX()
    @drawAxisY()

  drawAxisX: =>
    @display_axis_x = @view.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + @boundaries.height + ")");
    @display_axis_x.call(@xAxis.axis);

  redrawAxisX: =>
    @display_axis_x.call(@xAxis.axis);

  drawAxisY: =>
    @display_axis_y = @view.append("g")
      .attr("class", "y axis");
    @display_axis_y.call(@yAxis.axis);

  redrawAxisY: (bottom, top) =>
    scale = @yAxis.axis.scale()
    scale.domain(new Array(bottom, top))
    @display_axis_y.call(@yAxis.axis);

  track_mouse: (value) =>
    _axis = @xAxis

  stop_tracking: =>
    @overlay.on("mousemove", null)

  addLine: (line) =>
    @lines[line.name] = line

  drawLines: =>
    keys = Object.keys(@lines)
    for key, index in keys
      line = @lines[key]
      @drawLine(line)

  addBlock: (block) =>
    @blocks[block.name] = block

  drawBlocks: =>
    # console.log(@blocks)
    keys = Object.keys(@blocks)
    for key, index in keys
      block = @blocks[key]
      @drawLine(block)


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

      .attr("class", line.name + line.extension())
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

  removeAllLines: =>
    lines = _.keys(@lines)
    for line in lines
      @view.selectAll("." + line)
      .data([]).exit()
      .remove()

    @lines = {}


  removeBlocks: =>
    #for block in @blocks
    @view.selectAll(".line.block.area")
      .data([]).exit()
      .style("opacity", 0)
      .remove()
    @blocks = {}

class @BrushDisplay extends BaseDisplay
  constructor: (options) ->
    super(options)
    @drawAxis()
    b = @boundaries
    # @brush = d3.svg.brush()
    #   .x(@xAxis.domain.rangeband)
    #   .extent([0,0])
    #   .on("brush", ->
    #     console.log("brushed")
    #   )

    @svg_brush = d3.select(@select).append("svg")
      .attr("width", b.total_width)
      .attr("height", b.total_height)
      .attr("class", "brush")
      .attr(
        "transform",
        "translate(" +
        b.margin.left + "," +
        b.margin.top + ")"
      );

class @Display extends BaseDisplay
  constructor: (options) ->
    super(options)
    @drawAxis()

class @NavDisplay extends BaseDisplay
  constructor: (options) ->
    super(options)
    @drawAxis()


class @BaseLine
  constructor: (options={}) ->
    {@name, @valuesX, @valuesY, @domainX, @domainY} = options
    @_show = options.show ? !options.hide ? true
    @interpolation = options.interpolation ? "basis"
    @color = options.color ? new Color("black")


  className: =>
    "." + @name

  classNameLine: =>
    @className() + "-line"

  fullClassSpecifier: =>
    @className() + " " + @classNameLine()

  extension: =>
    "-line line"

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

  copy: (options={}) =>
    # copy = $.extend({}, @)
    copy = {}
    attributes = Object.keys(@)
    for key in attributes
      copy[key] = options[key] ? @[key]
    return copy

  deepCopy: (options={}) =>
    copy = $.extend(true, {}, @)
    for key, value of options
      copy[key] = value
    return copy

class @Line extends BaseLine
  constructor: (options={}) ->
    super(options)
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

class @ErrorLine extends Line
  constructor: (options = {}) ->
    super(options)

  extension: =>
    "-line line errorline"


  _opacity: =>
    return 0.45

class @Block extends BaseLine
  constructor: (options={}) ->
    super(options)
    @setup()

  setup: =>
    funcX = (d, i) ->
      @domainX.domain(@valuesX[i])
    funcY0 = (d,i) ->
      @domainY.domain(@valuesY[0])
    funcY1 = (d, i) ->
      @domainY.domain(@valuesY[1])
    @line = 
      d3.svg.area()
        .interpolate("basis")
        .x(funcX)
        .y0(funcY0)
        .y1(funcY1)

  extension: =>
    "-line line area block"

  getRangeX: =>
    return @valuesX

  getRangeY: =>
    return @valuesY


class @AreaLine extends BaseLine
  constructor: (options={}) ->
    super(options)
    @setup()

  setup: =>
    funcX = (d,i) ->
      @domainX.domain(@valuesX[i])
    funcY0 = (d,i) ->
      @domainY.domain(0)
    funcY1 = (d,i) ->
      @domainY.domain(@valuesY[i])
    @line =
      d3.svg.area()
        .interpolate("basis")
        .x(funcX)
        .y0(funcY0)
        .y1(funcY1)

  extension: =>
    "-line line area"


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

class @NavBar extends Line
  constructor: (options = {}) ->
    super(options)
    @key = options.key
    @valuesY = [@domainY.minVal(), @domainY.maxVal()]
    @color = new Color("gray")
    @setPosition(options.position)

  setPosition: (value) =>
    @valuesX = [value, value]


class @EstNavBar extends Line
  constructor: (options = {}) ->
    super(options)
    @key = options.key
    @valuesY = [@domainY.minVal(), @domainY.maxVal()]
    @color = options.color ? new Color("#ee0000")
    @setPosition(options.position)

  setPosition: (value) =>
    @valuesX = [value, value]


class @Color
  constructor: (options={}) ->
    @color = @getColor(options) if typeof options == "string"
    @color = @getColor(options.color) if typeof options == "object"

  getColor: (string = null) ->
    return d3.rgb(string) unless string == null
    @color

  setColor: (color) =>
    @color = @getColor(color)



class @Accumulator
  constructor: (options={}) ->
    @arrays = options.arrays ? []

  addArray: (array) =>
    @arrays.push(array)

  addArrays: (arrays = []) =>
    for array in arrays 
      @addArray(array)

  resetArrays: =>
    arrays = []

  getAccumulatedData: =>
    accumulatedData = []
    for angle, i in window.m.data_angles.angles
      accumulatedData[i] = 0
      for array in @arrays
        accumulatedData[i] += array[i]
    return accumulatedData


class @ErrorAccumulator
  constructor: (options = {}) ->
    @runs = options.runs ? []

  addRun: (run) =>
    @runs.push(run)

  addRuns: (runs = []) =>
    for run in runs 
      @addRun(run)

  resetRuns: =>
    runs = []

  getAccumulatedData: =>
    accumulatedData = []
    arrays = []
    for run in @runs
      arrays.push(Math.abs(window.m.measured_points.points - run.emulated_points.points))
    for angle, i in window.m.data_angles.angles
      for array in arrays
        accumulatedData[i] += array[i]
    return accumulatedData


